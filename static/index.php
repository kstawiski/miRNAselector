<?php
exec("chown -R mirnaselector /miRNAselector");
require_once 'class.formr.php';
if (!file_exists('/miRNAselector/var_status.txt')) { file_put_contents('/miRNAselector/var_status.txt', "[0] INITIAL (UNCONFIGURED)"); } // Wyjściowy status.
$status = file_get_contents('/miRNAselector/var_status.txt');


?>


<html>

<head>
    <title>miRNAselector</title>
    <script src="https://code.jquery.com/jquery-3.4.1.min.js"
        integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/ui/1.9.2/jquery-ui.js" type="text/javascript"></script>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
        integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous" />
    
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css"
        integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous" />
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
        integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous">
    </script>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="miRNAselector - a tool for selecting great miRNA biomarkers." />
    <meta name="author" content="Konrad Stawiski (konrad@konsta.com.pl)" />
    <link rel="stylesheet" href="css/starter-template.css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.12.1/js/all.min.js"
        integrity="sha256-MAgcygDRahs+F/Nk5Vz387whB4kSK9NXlDN3w58LLq0=" crossorigin="anonymous"></script>
    <script type="text/javascript">
        var waitingDialog = waitingDialog || (function ($) { 'use strict';

	// Creating modal dialog's DOM
	var $dialog = $(
		'<div class="modal fade" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog" aria-hidden="true" style="padding-top:15%; overflow-y:visible;">' +
		'<div class="modal-dialog modal-m">' +
		'<div class="modal-content">' +
			'<div class="modal-header"><h3 style="margin:0;"></h3></div>' +
			'<div class="modal-body">' +
				'<div class="progress progress-striped active" style="margin-bottom:0;"><div class="progress-bar" style="width: 100%"></div></div>' +
			'</div>' +
		'</div></div></div>');

	return {
		/**
		 * Opens our dialog
		 * @param message Custom message
		 * @param options Custom options:
		 * 				  options.dialogSize - bootstrap postfix for dialog size, e.g. "sm", "m";
		 * 				  options.progressType - bootstrap postfix for progress bar type, e.g. "success", "warning".
		 */
		show: function (message, options) {
			// Assigning defaults
			if (typeof options === 'undefined') {
				options = {};
			}
			if (typeof message === 'undefined') {
				message = 'Loading';
			}
			var settings = $.extend({
				dialogSize: 'm',
				progressType: '',
				onHide: null // This callback runs after the dialog was hidden
			}, options);

			// Configuring dialog
			$dialog.find('.modal-dialog').attr('class', 'modal-dialog').addClass('modal-' + settings.dialogSize);
			$dialog.find('.progress-bar').attr('class', 'progress-bar');
			if (settings.progressType) {
				$dialog.find('.progress-bar').addClass('progress-bar-' + settings.progressType);
			}
			$dialog.find('h3').text(message);
			// Adding callbacks
			if (typeof settings.onHide === 'function') {
				$dialog.off('hidden.bs.modal').on('hidden.bs.modal', function (e) {
					settings.onHide.call($dialog);
				});
			}
			// Opening dialog
			$dialog.modal();
		},
		/**
		 * Closes dialog
		 */
		hide: function () {
			$dialog.modal('hide');
		}
	};

})(jQuery);
    </script>
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

                        <button type="submit" class="btn btn-success" onclick="waitingDialog.show('Uploading & performing initial check...');" value="Upload" name="submit">
                        <i class="fas fa-upload"></i>&emsp;Upload
                        </button>
                    </form>

                    <?php } else { ?>

                    <pre><?php 
                        if(!file_exists("/miRNAselector/initial_check.txt")) {
                        system("Rscript /miRNAselector/miRNAselector/docker/1_formalcheckcsv.R > /miRNAselector/initial_check.txt"); echo file_get_contents("/miRNAselector/initial_check.txt"); } else { echo file_get_contents("/miRNAselector/initial_check.txt"); }?></pre>
                    <p>Initial check status:
                        <code><b><?php $var_initcheck = file_get_contents('/miRNAselector/var_initcheck.txt'); echo $var_initcheck; ?></b></code>
                    </p>
                    <p><a href="view.php?f=data_start.csv" class="btn btn-info" role="button" target="popup"
                        onclick="window.open('view.php?f=data_start.csv','popup','width=600,height=600'); return false;">View
                        data</a> <a href="process.php?type=cleandata" class="btn btn-danger" role="button" onclick="return confirm('Are you sure? This will delete all the data, configuration files and results. If you did not save them, click cancel and do it in the first place!')">Delete data
                        and restart the pipeline!</a></p>
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

echo "<hr><h3>Preprocessing:</h3>";

// Korekcja
$options = array(
    'yes'    => 'Yes (correct column names to latest version of miRbase)',
    'no'    => 'No (do not correct names)'
  );
echo $form->input_select('correct_names', 'Correct human miRNA names (correct aliases using latest version of miRbase; ignored for non-miRNA features):','','','','','yes',$options);

// Co na wejsciu
if(file_get_contents('/miRNAselector/var_seemslikecounts.txt') == "TRUE") {
    $options = array(
        'counts'    => 'Read counts (require transformation to log10(TPM))',
        'transformed'    => 'Already normalized (e.g. log(TPM), deltaCt)',
      );
      echo $form->input_select('input_format', 'Input features format:','','','','','counts',$options);
} else {
    $options = array(
        'transformed'    => 'Already normalized (e.g. log(TPM), deltaCt)'
      );
      echo $form->input_select('input_format', 'Input features format:','','','','','transformed',$options);
}

echo "<p>If you choose counts - the counts will be transformed to TPM (counts/transcripts per milion, normalized suppressMessages(library sizes are not used). The value 0.001 is later added to TPM values and those are later log10-transformed, meaning that value -3 is considered as no expression.</p>";

// Korekcja
if(file_get_contents('/miRNAselector/var_seemslikecounts.txt') == "TRUE") {
$options = array(
    'yes'    => 'Yes',
    'no'    => 'No'
  );
echo $form->input_select('filtration', 'Simple feature filtration prior to analysis:','','','','','yes',$options);
echo "<p>Prior to analysis, the variables can be selected based on arbitrary filter. For example, the researcher may assume that the miRNAs of interest have to be present in the quantitity of more than 100 counts in more than 1/3 of cases. Tweak the options below if you want to use filtration.</p>";

echo $form->input_text('filtration_mincounts', '(Optional) Minimal number of counts: [values: >=0]','100');
echo $form->input_text('filtration_propotion', '(Optional) Minimal proportion of cases: [values: 0-1]','0.5');
}

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

// Split
echo $form->input_text('training_split', 'Proportion of training set cases: [values: 0-1]','0.6');
echo "<p>The pipeline splits dataset into training, testing and validation sets. This value allows to set the proportion of dataset (by default 60%) that will remain in training set. The rest of cases will be evenly splitted to testing and validation set. E.g. 0.6 = 60% of cases in training set, 20% in testing and 20% in validation set.</p>";

echo "<hr><h3>Feature selection:</h3>";

echo "<table class=\"table\"><thead><tr><th> </th><th>Method:</th><th>Description:</th></tr></thead><tbody>";

echo "<tr><td>";
echo $form->input_checkbox('method1','</td><td style="white-space: nowrap"><code>1</code>&emsp;<code>[all]</code>','yes','','','','checked');
echo "<td>". "All features (e.g. miRNAs) in dataset." . "</td>";
echo "</td><tr>";

echo "<tr><td>";
echo $form->input_checkbox('method2','</td><td style="white-space: nowrap"><code>2</code>&emsp;<code>[sig]</code>','yes','','','','checked');
echo "<td>". "Significiance filter. Features that differ significantly (p<0.05) between groups, verifed by Welch two samples t-test. P-values are adjusted using Benjamini and Hochberg method." . "</td>";
echo "</td><tr>";



echo "</tbody></table>";

echo $form->input_submit('', '', 'Save configuration and start the pipeline', 'submit', 'class="btn btn-success"');
echo $form->form_close();

?>


                </div>
            </div>
                    <?php } ?>

        </div>

<?php 
// if($status == "[2] PROCESSING") {
    $max_analysis_steps = exec("grep -o \"ks.docker.update_progress\" /miRNAselector/miRNAselector/templetes/*.* | wc -l");
    $current_steps = file_get_contents("/miRNAselector/var_progress.txt");
?>


<div class="panel panel-default">
    <!-- Default panel contents -->
    <div class="panel-heading">Processing progress</div>
        <div class="panel-body">
            <p>Progress: <?php echo(file_get_contents("/miRNAselector/var_progress.txt") . "out of " . $max_analysis_steps . " steps"); ?></p>
        </div>

        <!-- Table -->
        <table class="table">
            <thead>
                <tr>
                    <th>Heading 1</th>
                </tr>
                <tr>
                    <th>Heading 2</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>Content 1</td>
                </tr>
                <tr>
                    <td>Content 2</td>
                </tr>
            </tbody>
        </table>
</div>




<?php
// }
?>


        <div class="panel panel-default">
                <div class="panel-heading"><i class="fas fa-bars"></i>&emsp;&emsp;Additional tools</div>
                <div class="panel-body"><button type="button" class="btn btn-info" data-toggle="modal"
                        data-target="#modalYT"><i class="fas fa-tv"></i>&emsp;System monitor</button>&emsp;
                    <a href="e" target="_blank" role="button" class="btn btn-primary"><i class="fas fa-lock-open"></i>&emsp;Advanced features</a>
                    &emsp;<a href="process.php?type=init_update" role="button" onclick="waitingDialog.show('Starting update...');" class="btn btn-primary"><i class="fas fa-arrow-up"></i></i>&emsp;Update</a>
                    &emsp;<a href="e/notebooks/miRNAselector/vignettes/Tutorial.Rmd" role="button" onclick="waitingDialog.show('Loading...');" class="btn btn-primary"><i class="fas fa-graduation-cap"></i>&emsp;Learn R package</a>
                    &emsp;<button type="button" class="btn btn-info" data-toggle="modal" data-target="#modalYT2"><i class="fas fa-terminal"></i>&emsp;Shell</button></div>
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


        <!--Modal: Name-->
        <div class="modal fade" id="modalYT2" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">

            <!--Content-->
            <div class="modal-content">

                <!--Body-->
                <div class="modal-body mb-0 p-0">

                    <div class="embed-responsive embed-responsive-16by9 z-depth-1-half">
                        <iframe class="embed-responsive-item" src="shell.php" allowfullscreen></iframe>
                    </div>

                </div>

                <!--Footer-->
                <div class="modal-footer justify-content-center">
                    <span class="mr-4">More advanced terminal features are available via Jupyter-based advanced features.</span>

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