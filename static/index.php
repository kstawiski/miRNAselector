<?php
require_once 'class.formr.php';
if (!file_exists('/miRNAselector/var_status.txt')) { file_put_contents('/miRNAselector/var_status.txt', "[0] INITIAL (UNCONFIGURED)"); } // Wyjściowy status.
$status = file_get_contents('/miRNAselector/var_status.txt');


?>


<html>

<head>
    <title>miRNAselector</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
        integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous" />
    <script src="https://code.jquery.com/jquery-3.4.1.min.js"
        integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"></script>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css"
        integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous" />
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
        integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous">
    </script>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.12.1/js/all.min.js"
        integrity="sha256-MAgcygDRahs+F/Nk5Vz387whB4kSK9NXlDN3w58LLq0=" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-1.8.3.min.js" type="text/javascript"></script>
    <script src="https://code.jquery.com/ui/1.9.2/jquery-ui.js" type="text/javascript"></script>
</head>

<body>

    <div class="container">
        <div class="starter-template">
            <p>
                <center><img src="logo.png" width="70%" />
            </p>
            <p><br></p>
        </div>
        <p>Welcome to <b>miRNAselector</b> - the software intended to find the best biomarker signiture based on NGS (miRNA-seq, RNA-seq) and
            qPCR data.</p>
        <div class="panel-group">
            <?php if ($_GET["msg"] != "") { ?>
            <div class="panel panel-danger">
                <div class="panel-heading"><i class="fas fa-exclamation-triangle"></i></i>&emsp;&emsp;MESSAGE</div>
                <div class="panel-body"><b><?php echo htmlentities($_GET['msg']); ?></b></div>
            </div>
            <?php } ?>
            <div class="panel panel-primary">
                <div class="panel-heading"><i class="fas fa-info"></i>&emsp;&emsp;PIPELINE STATUS</div>
                <div class="panel-body">STATUS: <code><b><?php echo $status; ?></b></code></div>
            </div>

            
<?php if($status != "[2] PROCESSING") { ?>
            <div class="panel panel-success">
                <div class="panel-heading"><i class="fas fa-cloud-upload-alt"></i>&emsp;&emsp;Upload the file and start
                    the pipeline</div>
                <div class="panel-body">

                    <?php if(!file_exists("/miRNAselector/data.csv")) { ?>

                    <form action="process.php?type=upload" method="post" enctype="multipart/form-data">
                        <p>Select <code>.csv</code> file to upload:</p>
                        <input type="file" class="form-control-file" id="fileToUpload" name="fileToUpload"><br />
                        <input type="submit" class="btn btn-primary" value="Upload Image" name="submit">
                    </form>

                    <?php } else { ?>

                    <pre><?php system("Rscript /miRNAselector/miRNAselector/docker/1_formalcheckcsv.R"); ?></pre>
                    <p>Initial check status:
                        <code><b><?php $var_initcheck = file_get_contents('/miRNAselector/var_initcheck.txt'); echo $var_initcheck; ?></b></code>
                    </p>
                    <p><a href="view.php?f=data.csv" class="btn btn-info" role="button" target="popup"
                        onclick="window.open('view.php?f=data.csv','popup','width=600,height=600'); return false;">View
                        data</a> <a href="process.php?type=cleandata" class="btn btn-danger" role="button">Delete data
                        and reupload</a></p>
<p><font size="1">Notes: <i>The viewer is limited to 100 columns and 1000 rows.</i></font></p>
                    <?php } ?>

                </div>
            </div>
                    <?php } ?>

<?php if($status == "[1] DATA UPLOADED (UNCONFIGURED)" && $var_initcheck == "OK") { ?>
            <div class="panel panel-default">
                <div class="panel-heading"><i class="fas fa-tools"></i>&emsp;&emsp;Configure the pipeline</div>
                <div class="panel-body">

<?php
$form = new Formr('bootstrap');
echo $form->form_open('','','process.php?type=configure');

echo $form->input_text('project_name','Project name (will be printed on analysis reports):');

// Co na wejsciu
$options = array(
  'counts'    => 'Read counts (require transformation to log10(TPM) and filtration)',
  'countswithoutfilter'    => 'Read counts (require transformation to log10(TPM) but no filtration)',
  'transformed'    => 'Already normalized and filtered values (e.g. log(TPM), deltaCt)',
);
echo $form->input_select('input_format', 'Input features format:','','','','','counts',$options);

// Korekcja
$options = array(
    'yes'    => 'Yes (correct column names to latest version of miRbase)',
    'no'    => 'No (do not correct names)'
  );
echo $form->input_select('correct_names', 'Correct miRNA names (correct aliases using latest version of miRbase; ignored for non-miRNA features):','','','','','yes',$options);

// Jeśli missing
if(file_get_contents('/miRNAselector/var_missing.txt') == "TRUE") {
$options = array(
  'pmm'    => 'Use predictive mean matching for missing data imputation',
  'mean'  => 'Use mean value for variable for missing data imputation',
  'median'  => 'Use median value for variable for missing data imputation',
  'discard'  => 'Discard cases with missing values',
);
echo $form->input_select('missing_imput', 'Missing data imputation:','','','','','pmm',$options);
}

// Jeśli batch
if(file_get_contents('/miRNAselector/var_batch.txt') == "TRUE") {
  $options = array(
    'no'    => 'Do not correct batch effect',
    'yes1'  => 'Correct batch effect with ComBat (model: ~ Batch)',
    'yes2'  => 'Correct batch effect with ComBat and with Class as covariate (model: ~ Batch + Class)',
  );
  echo $form->input_select('correct_batch', 'Batch effect correction:','','','','','no',$options);
}


echo $form->input_submit('', '', 'Save configuration and start the pipeline', 'submit', 'class="btn btn-success"');
echo $form->form_close();
?>


                </div>
            </div>
                    <?php } ?>

        </div>




        <div class="panel panel-default">
                <div class="panel-heading"><i class="fas fa-bars"></i>&emsp;&emsp;Additional tools</div>
                <div class="panel-body"><button type="button" class="btn btn-info" data-toggle="modal"
                        data-target="#modalYT"><i class="fas fa-tv"></i>&emsp;System monitor</button>&emsp;
                    <a href="e" target="_blank" role="button" class="btn btn-danger"><i
                            class="fas fa-lock-open"></i>&emsp;Advanced features</a></div>
            </div>

    </div>
    <!--Modal: Name-->
    <div class="modal fade" id="modalYT" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">

            <!--Content-->
            <div class="modal-content">

                <!--Body-->
                <div class="modal-body mb-0 p-0">

                    <div class="embed-responsive embed-responsive-16by9 z-depth-1-half">
                        <iframe class="embed-responsive-item" src="top.php" allowfullscreen></iframe>
                    </div>

                </div>

                <!--Footer-->
                <div class="modal-footer justify-content-center">
                    <span class="mr-4">Running <code>top</code> every 2 seconds...</span>

                    <button type="button" class="btn btn-outline-primary btn-rounded btn-md ml-4"
                        data-dismiss="modal">Close</button>

                </div>

            </div>
            <!--/.Content-->

        </div>
    </div>
    <!--Modal: Name-->
    <hr />
    <footer class="footer">
        <div class="container">
            <span class="text-muted">miRNAselector by Konrad Stawiski and Marcin Kaszkowiak&emsp;&emsp;&emsp;&emsp;<i
                    class="fas fa-envelope"></i> konrad@konsta.com.pl&emsp;&emsp;&emsp;<i
                    class="fas fa-globe-europe"></i>
                <a href="https://biostat.umed.pl" taret="_blank">https://biostat.umed.pl</a>&emsp;&emsp;&emsp;<i
                    class="fab fa-github"></i> <a href="https://github.com/kstawiski/miRNAselector"
                    target="_blank">https://github.com/kstawiski/miRNAselector</a></span>
        </div>
    </footer>
    <!-- /.container -->
</body>

</html>