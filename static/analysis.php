<?php
$target_dir = "/miRNAselector/" . $_GET['id'] . "/";
if(!file_exists($target_dir . "initial_check.txt")) { $msg .= "This analysis does not exist. Please check if your analysis id is correct."; $msg = urlencode($msg); header("Location: /index.php?msg=" . $msg); die(); }
session_start();
$_SESSION["analysis_id"]=$_GET['id'];
?>
<html>

<head>
    <title>miRNAselector</title>
    <script src="jquery-3.4.1.min.js"
        integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"></script>
    <script src="jquery-ui.js" type="text/javascript"></script>
    <link rel="stylesheet" href="bootstrap.min.css"
        integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous" />
    <link rel="stylesheet" href="bootstrap-theme.min.css"
        integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous" />
    <script src="bootstrap.min.js"
        integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous">
    </script>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="miRNAselector - a tool for selecting great miRNA biomarkers." />
    <meta name="author" content="Konrad Stawiski (konrad@konsta.com.pl)" />
    <link rel="stylesheet" href="css/starter-template.css" />
    <script src="all.min.js"
        integrity="sha256-MAgcygDRahs+F/Nk5Vz387whB4kSK9NXlDN3w58LLq0=" crossorigin="anonymous"></script>
    <!-- Global site tag (gtag.js) - Google Analytics -->
    <script async src="https://www.googletagmanager.com/gtag/js?id=UA-53584749-8"></script>
    <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());

    gtag('config', 'UA-53584749-8');
    </script>
    <script type="text/javascript">
    $(".btn-success").click(function (event) {
        waitingDialog.show('Processing.. Please wait...');
            });
    
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
        <div class="panel-group">
            <?php if ($_GET["msg"] != "") { ?>
            <div class="panel panel-danger">
                <div class="panel-heading"><i class="fas fa-exclamation-triangle"></i></i>&emsp;&emsp;MESSAGE</div>
                <div class="panel-body"><b><?php echo htmlentities($_GET['msg']); ?></b></div>
            </div>
            <?php } ?>
            
            <div class="panel panel-primary">
                <div class="panel-heading"><i class="fas fa-info"></i>&emsp;&emsp;Analysis</div>
                <div class="panel-body"><p>Analysis ID: <code><b><?php echo $_GET['id']; ?></b></code></p><p><font size="1">Please save this analysis id for any further reference. If you loose it, you will not be able to resume your analysis.</font></p></div>
            </div>
            
            <div class="panel panel-info">
                <div class="panel-heading"><i class="fas fa-table"></i>&emsp;&emsp;Data</div>
                <div class="panel-body">
                <p>Initial check status:
                <pre style="white-space: pre-wrap;"><?php echo file_get_contents($target_dir . "initial_check.txt"); ?></pre>
                </p>
                <p>Initial check status:
                        <code><b><?php $var_initcheck = file_get_contents($target_dir . 'var_initcheck.txt'); echo $var_initcheck; ?></b></code>
                    </p>
                    <p><a href="view.php?f=<?php echo $_GET['id']; ?>/data_start.csv" class="btn btn-info" role="button" target="popup"
                        onclick="window.open('view.php?f=<?php echo $_GET['id']; ?>/data_start.csv','popup','width=600,height=600'); return false;">View
                        data</a></p>
<p><font size="1">Notes: <i>The viewer is limited to 100 columns and 1000 rows.</i></font></p></div>
            </div>

            <div class="panel panel-primary">
            <div class="panel-heading"><i class="fas fa-chart-bar"></i>&emsp;&emsp;Exploratory analysis</div>
            <div class="panel-body">
<?php
$images = glob($target_dir."exploratory_*.png");
foreach($images as $image) {
    $image3 = str_replace("/miRNAselector","/e/files", $image);
    $image2 = str_replace("/miRNAselector","/e/view", $image);
    echo '<a href="'.$image2.'" target="_blank" onclick="window.open(\''. $image2 . '\',\'popup\',\'width=600,height=600\'); return false;"><img src="'.$image3.'" width="49%" /></a>';
}
?>
<p><font size="1">Notes: <i>If mix is not labeled the heatmap was constructed based on training set. Some of the heatmaps use raw expression, some using z-scoring. Features marked on vulcano plot are significant in DE. You can re-create and customize those plots below.</i></font></p></div>
<table class="table">

<tbody>

<tr>
<td>Training set:</td>
<td><a href="view.php?f=<?php echo $_GET['id']; ?>/mixed_train.csv" class="btn btn-info" role="button" target="popup"
                        onclick="window.open('view.php?f=<?php echo $_GET['id']; ?>/mixed_train.csv','popup','width=600,height=600'); return false;"><i class="fas fa-search-plus"></i> View</a>&emsp;<a href="/e/files/<?php echo $_GET['id']; ?>/mixed_train.csv"  class="btn btn-warning" ><i class="fas fa-download"></i> Download</a></td>
</tr>

<tr>
<td>Testing set:</td>
<td><a href="view.php?f=<?php echo $_GET['id']; ?>/mixed_test.csv" class="btn btn-info" role="button" target="popup"
                        onclick="window.open('view.php?f=<?php echo $_GET['id']; ?>/mixed_test.csv','popup','width=600,height=600'); return false;"><i class="fas fa-search-plus"></i> View</a>&emsp;<a href="/e/files/<?php echo $_GET['id']; ?>/mixed_test.csv"  class="btn btn-warning" ><i class="fas fa-download"></i> Download</a></td>
</tr>

<tr>
<td>Validation set:</td>
<td><a href="view.php?f=<?php echo $_GET['id']; ?>/mixed_valid.csv" class="btn btn-info" role="button" target="popup"
                        onclick="window.open('view.php?f=<?php echo $_GET['id']; ?>/mixed_valid.csv','popup','width=600,height=600'); return false;"><i class="fas fa-search-plus"></i> View</a>&emsp;<a href="/e/files/<?php echo $_GET['id']; ?>/mixed_valid.csv"  class="btn btn-warning" ><i class="fas fa-download"></i> Download</a></td>
</tr>

<tr>
<td>Differential expression analysis (training set only):</td>
<td><a href="view.php?f=<?php echo $_GET['id']; ?>/DE_train.csv" class="btn btn-info" role="button" target="popup"
                        onclick="window.open('view.php?f=<?php echo $_GET['id']; ?>/DE_train.csv','popup','width=600,height=600'); return false;"><i class="fas fa-search-plus"></i> View</a>&emsp;<a href="/e/files/<?php echo $_GET['id']; ?>/DE_train.csv"  class="btn btn-warning" ><i class="fas fa-download"></i> Download</a></td>
</tr>

<tr>
<td>Differential expression analysis (whole dataset):</td>
<td><a href="view.php?f=<?php echo $_GET['id']; ?>/DE_mixed.csv" class="btn btn-info" role="button" target="popup"
                        onclick="window.open('view.php?f=<?php echo $_GET['id']; ?>/DE_mixed.csv','popup','width=600,height=600'); return false;"><i class="fas fa-search-plus"></i> View</a>&emsp;<a href="/e/files/<?php echo $_GET['id']; ?>/DE_mixed.csv"  class="btn btn-warning" ><i class="fas fa-download"></i> Download</a></td>
</tr>

<tr>
<td>Re-do the initial check and default exploratory analysis:</td>
<td><a href="/e/notebooks/<?php echo $_GET['id']; ?>/formalcheckcsv.R" class="btn btn-danger" role="button" target="popup"
                        onclick="window.open('/e/notebooks/<?php echo $_GET['id']; ?>/formalcheckcsv.R','popup','width=600,height=600'); return false;"><i class="fas fa-play"></i> Run</a></td>
</tr>

<tr>
<td>Create your own analysis:</td>
<td><a href="/e/notebooks/<?php echo $_GET['id']; ?>/own_analysis.R" class="btn btn-danger" role="button" target="popup"
                        onclick="window.open('/e/notebooks/<?php echo $_GET['id']; ?>/own_analysis.R','popup','width=600,height=600'); return false;"><i class="fas fa-play"></i> Run</a></td>
</tr>

</tbody>
</table>
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
                    <p>&emsp;</p>
        </div>
    </footer>
    <!-- /.container -->
</body>

</html>


