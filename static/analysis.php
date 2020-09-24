<?php
$target_dir = "/miRNAselector/" . $_GET['id'] . "/";
if(!file_exists($target_dir . "initial_check.txt")) { $msg .= "This analysis does not exist. Please check if your analysis id is correct."; $msg = urlencode($msg); header("Location: /index.php?msg=" . $msg); die(); }
session_start();
$_SESSION["analysis_id"]=$_GET['id'];

// Czy jest task in progress?
$pid = shell_exec("ps -ef | grep -v grep | grep mirnaselector-" . $_GET['id'] ." | awk '{print $2}'");
if ($pid != "") { header("Location: /inprogress.php?id=" . $_GET['id']); die(); }

// Funkcje specyficzne
function konsta_readcsv($filename, $header=false) {
  $handle = fopen($filename, "r");
  echo '<table class="table">';
  //display header row if true
  if ($header) {
      $csvcontents = fgetcsv($handle);
      echo '<tr>';
      foreach ($csvcontents as $headercolumn) {
          echo "<th>$headercolumn</th>";
      }
      echo '</tr>';
  }
  // displaying contents
  while ($csvcontents = fgetcsv($handle)) {
      echo '<tr>';
      foreach ($csvcontents as $column) {
          echo "<td>$column</td>";
      }
      echo '</tr>';
  }
  echo '</table>';
  fclose($handle);
  }

  function konsta_readcsv_formulas($filename, $header=true) {
    $handle = fopen($filename, "r");
    echo '<table class="table">';
    //display header row if true
    if ($header) {
        $csvcontents = fgetcsv($handle);
        echo '<tr>';
        // foreach ($csvcontents as $headercolumn) {
        //     echo "<th>$headercolumn</th>";
        // }
        echo '<th>Name</th><th>Features</th><th>Count</th>';
        echo '</tr>';
    }
    // displaying contents
    while ($csvcontents = fgetcsv($handle)) {
        echo '<tr>';
        foreach ($csvcontents as $column) {
            echo "<td><code>$column</code></td>";
        }
        echo '</tr>';
    }
    echo '</table>';
    fclose($handle);
    }

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
    <style>
/* The switch - the box around the slider */
.switch {
  position: relative;
  display: inline-block;
  width: 60px;
  height: 34px;
}

/* Hide default HTML checkbox */
.switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

/* The slider */
.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #ccc;
  -webkit-transition: .4s;
  transition: .4s;
}

.slider:before {
  position: absolute;
  content: "";
  height: 26px;
  width: 26px;
  left: 4px;
  bottom: 4px;
  background-color: white;
  -webkit-transition: .4s;
  transition: .4s;
}

input:checked + .slider {
  background-color: #2196F3;
}

input:focus + .slider {
  box-shadow: 0 0 1px #2196F3;
}

input:checked + .slider:before {
  -webkit-transform: translateX(26px);
  -ms-transform: translateX(26px);
  transform: translateX(26px);
}

/* Rounded sliders */
.slider.round {
  border-radius: 34px;
}

.slider.round:before {
  border-radius: 50%;
}

/* Tooltip container */
.tooltip {
  position: relative;
  display: inline-block;
  border-bottom: 1px dotted black; /* If you want dots under the hoverable text */
}

/* Tooltip text */
.tooltip .tooltiptext {
  visibility: hidden;
  width: 120px;
  background-color: black;
  color: #fff;
  text-align: center;
  padding: 5px 0;
  border-radius: 6px;
 
  /* Position the tooltip text - see examples below! */
  position: absolute;
  z-index: 1;
}

/* Show the tooltip text when you mouse over the tooltip container */
.tooltip:hover .tooltiptext {
  visibility: visible;
}
    </style>
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

<?php if(!file_exists($target_dir . "featureselection_formulas_all.csv"))  { ?>
        <div class="panel panel-primary">
            <div class="panel-heading"><i class="fas fa-microscope"></i>&emsp;&emsp;Feature selection</div>
            <div class="panel-body">
<p><font size="1">Notes: <i>By the defult all the methods are selected, but you can turn some of them off.</i></font></p>
<table class="table">
<form action="process.php?type=new_fs" method="post">
<input type="hidden" id="analysisid" name="analysisid" value="<?php echo $_GET['id']; ?>">
<thead><th>Select</th><th>ID</th><th>Description</th></td></thead>
<tbody>
<tr>
    <td><label class="switch"><input type="checkbox" name="method[]" value="1" checked><span class="slider round"></span></label></td>
    <td>No: 1<br /><code>all<code></td>
    <td>Get all features (all features staring with 'hsa').</td>
</tr>
<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="2" checked><span class="slider round"></span></label></td>
    <td>No: 2<br /><code>sig, sigtop, sigtopBonf, sigtopHolm, topFC, sigSMOTE, sigtopSMOTE, sigtopBonfSMOTE, sigtopHolmSMOTE, topFCSMOTE</code></td>
    <td>Selects features significantly differently expressed between classes by performing unpaired t-test with and without correction for multiple testing. We get: <code>sig</code> - all significant (adjusted p-value less or equal to 0.05) miRNAs with comparison using unpaired t-test and after the Benjamini-Hochberg procedure (BH, false discovery rate); <code>sigtop</code> - <code>sig</code> but limited only to the your prefered number of features (most significant features sorted by p-value), <code>sigtopBonf</code> - uses Bonferroni instead of BH correction, <code>sigtopHolm</code> - uses Holm–Bonferroni instead of BH correction, <code>topFC</code> - selects prefered number of features based on decreasing absolute value of fold change in differential analysis.
    <br />All the methods are also checked on dataset balanced with SMOTE (<a href="https://arxiv.org/pdf/1106.1813.pdf" target="_blank">Synthetic Minority Oversampling TEchnique</a>) - those formulas which names are appended with <code>SMOTE</code>.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="3" checked><span class="slider round"></span></label></td>
    <td>No: 3<br /><code>fcsig, fcsigSMOTE</code></td>
    <td>Features significant in DE analysis using unpaired t-test and which absolute log2FC is greater than 1. Thus, features significant and up- or down-regulated in the higher magnitudes. FC - fold-change, DE - differential analysis.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="4" checked><span class="slider round"></span></label></td>
    <td>No: 4<br /><code>cfs, cfsSMOTE, cfs_sig, cfsSMOTE_sig</code></td>
    <td><a href="https://www.cs.waikato.ac.nz/~mhall/thesis.pdf" target="_blank">Correlation-based feature selection</a> (CFS) - a heuristic algorithm selecting features that are highly correlated with class (binary) and lowly correlated with one another. It explores a search space in best-first manner, until stopping criteria are met.</td>
</tr>


<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="5" checked><span class="slider round"></span></label></td>
    <td>No: 5<br /><code>classloop</code></td>
    <td>Classifier loop - performs multiple classification procedures using various algorithms (with embedded feature ranking) and various performance metrices. Final feature selection is done by combining the results. Modeling methods used: support vector machines, linear discriminant a nalysis, random forest and nearest shrunken centroid. Features are selected based on the AUC ROC and assessed in k-fold cross-validation according to the <a href="https://www.rdocumentation.org/packages/Biocomb/versions/0.4/topics/classifier.loop" target="_blank">documentation</a>. As this requires time, we do not perform it on SMOTEd dataset.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="6" checked><span class="slider round"></span></label></td>
    <td>No: 6<br /><code>classloopSMOTE</code></td>
    <td>Application of <code>classloop</code> on balanced dataset (with SMOTE).</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="7" checked><span class="slider round"></span></label></td>
    <td>No: 7<br /><code>classloop_sig</code></td>
    <td>Application of <code>classloop</code> but only on the features which are significant in DE.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="8" checked><span class="slider round"></span></label></td>
    <td>No: 8<br /><code>classloopSMOTE_sig</code></td>
    <td>Application of <code>classloop</code> on balanced training set and only on the features which are significant in DE (after balancing).</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="9" checked><span class="slider round"></span></label></td>
    <td>No: 9<br /><code>fcfs</code></td>
    <td>An algorithm similar to CFS, though exploring search space in greedy forward search manner (adding one, most attractive, feature at the time, until such addition does not improve set’s overall quality). Based on <a href="http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.411.9868&rep=rep1&type=pdf" target="_blank">Wang et al. 2005</a> and documented <a href="https://www.rdocumentation.org/packages/Biocomb/versions/0.4/topics/select.forward.Corr" target="_blank">here</a>.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="10" checked><span class="slider round"></span></label></td>
    <td>No: 10<br /><code>fcfsSMOTE</code></td>
    <td>Application of <code>fcfs</code> on balanced training set.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="11" checked><span class="slider round"></span></label></td>
    <td>No: 11<br /><code>fcfs_sig</code></td>
    <td>Application of <code>fcfs</code> on features significant in DE.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="12" checked><span class="slider round"></span></label></td>
    <td>No: 12<br /><code>fcfsSMOTE_sig</code></td>
    <td>Application of <code>fcfs</code> on balanced dataset and on features significant in DE (after balancing).</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="13" checked><span class="slider round"></span></label></td>
    <td>No: 13<br /><code>fwrap</code></td>
    <td>A decision tree algorithm and forward search strategy documented <a href="https://www.rdocumentation.org/packages/Biocomb/versions/0.4/topics/select.forward.wrapper" target="_blank">here</a>.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="14" checked><span class="slider round"></span></label></td>
    <td>No: 14<br /><code>fwrapSMOTE</code></td>
    <td>Application of <code>fwrap</code> on balanced training set.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="15" checked><span class="slider round"></span></label></td>
    <td>No: 15<br /><code>fwrap_sig</code></td>
    <td>Application of <code>fwrap</code> on features significant in DE.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="16" checked><span class="slider round"></span></label></td>
    <td>No: 16<br /><code>fwrapSMOTE_sig</code></td>
    <td>Application of <code>fwrap</code> on balanced dataset and on features significant in DE (after balancing).</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="17" checked><span class="slider round"></span></label></td>
    <td>No: 17<br /><code>AUC_MDL</code></td>
    <td>Feature ranking based on ROC AUC and minimal description length (MDL) discretization algorithm documented <a href="https://www.rdocumentation.org/packages/Biocomb/versions/0.4/topics/select.process" target="_blank">here</a>. After the ranking, the number of features are limited as set in options below.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="18" checked><span class="slider round"></span></label></td>
    <td>No: 18<br /><code>SU_MDL</code></td>
    <td>Feature ranking based on symmetrical uncertainty and minimal description length (MDL) discretization algorithm documented <a href="https://www.rdocumentation.org/packages/Biocomb/versions/0.4/topics/select.process" target="_blank">here</a>. After the ranking, the number of features are limited as set in options below.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="19" checked><span class="slider round"></span></label></td>
    <td>No: 19<br /><code>CorrSF_MDL</code></td>
    <td>Feature ranking based on CFS algorithm with forward search and minimal description length (MDL) discretization algorithm documented <a href="https://www.rdocumentation.org/packages/Biocomb/versions/0.4/topics/select.process" target="_blank">here</a>. After the ranking, the number of features are limited as set in options below.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="20" checked><span class="slider round"></span></label></td>
    <td>No: 20<br /><code>AUC_MDLSMOTE</code></td>
    <td>Feature ranking based on ROC AUC and minimal description length (MDL) discretization algorithm documented <a href="https://www.rdocumentation.org/packages/Biocomb/versions/0.4/topics/select.process" target="_blank">here</a>. After the ranking, the number of features are limited as set in options below. Performed on the training set balanced with SMOTE.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="21" checked><span class="slider round"></span></label></td>
    <td>No: 21<br /><code>SU_MDLSMOTE</code></td>
    <td>Feature ranking based on symmetrical uncertainty and minimal description length (MDL) discretization algorithm documented <a href="https://www.rdocumentation.org/packages/Biocomb/versions/0.4/topics/select.process" target="_blank">here</a>. After the ranking, the number of features are limited as set in options below. Performed on the training set balanced with SMOTE.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="22" checked><span class="slider round"></span></label></td>
    <td>No: 22<br /><code>CorrSF_MDLSMOTE</code></td>
    <td>Feature ranking based on CFS algorithm with forward search and minimal description length (MDL) discretization algorithm documented <a href="https://www.rdocumentation.org/packages/Biocomb/versions/0.4/topics/select.process" target="_blank">here</a>. After the ranking, the number of features are limited as set in options below. Performed on the training set balanced with SMOTE.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="23" checked><span class="slider round"></span></label></td>
    <td>No: 23<br /><code>AUC_MDL_sig</code></td>
    <td>Feature ranking based on ROC AUC and minimal description length (MDL) discretization algorithm documented <a href="https://www.rdocumentation.org/packages/Biocomb/versions/0.4/topics/select.process" target="_blank">here</a>. After the ranking, the number of features are limited as set in options below. Only features significant in DE are allowed.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="24" checked><span class="slider round"></span></label></td>
    <td>No: 24<br /><code>SU_MDL_sig</code></td>
    <td>Feature ranking based on symmetrical uncertainty and minimal description length (MDL) discretization algorithm documented <a href="https://www.rdocumentation.org/packages/Biocomb/versions/0.4/topics/select.process" target="_blank">here</a>. After the ranking, the number of features are limited as set in options below. Only features significant in DE are allowed.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="25" checked><span class="slider round"></span></label></td>
    <td>No: 25<br /><code>CorrSF_MDL_sig</code></td>
    <td>Feature ranking based on CFS algorithm with forward search and minimal description length (MDL) discretization algorithm documented <a href="https://www.rdocumentation.org/packages/Biocomb/versions/0.4/topics/select.process" target="_blank">here</a>. After the ranking, the number of features are limited as set in options below. Only features significant in DE are allowed.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="26" checked><span class="slider round"></span></label></td>
    <td>No: 26<br /><code>AUC_MDLSMOTE_sig</code></td>
    <td>Feature ranking based on ROC AUC and minimal description length (MDL) discretization algorithm documented <a href="https://www.rdocumentation.org/packages/Biocomb/versions/0.4/topics/select.process" target="_blank">here</a>. After the ranking, the number of features are limited as set in options below. Performed on the training set balanced with SMOTE. Only features significant in DE are allowed.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="27" checked><span class="slider round"></span></label></td>
    <td>No: 27<br /><code>SU_MDLSMOTE_sig</code></td>
    <td>Feature ranking based on symmetrical uncertainty and minimal description length (MDL) discretization algorithm documented <a href="https://www.rdocumentation.org/packages/Biocomb/versions/0.4/topics/select.process" target="_blank">here</a>. After the ranking, the number of features are limited as set in options below. Performed on the training set balanced with SMOTE. Only features significant in DE are allowed.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="28" checked><span class="slider round"></span></label></td>
    <td>No: 28<br /><code>CorrSF_MDLSMOTE_sig</code></td>
    <td>Feature ranking based on CFS algorithm with forward search and minimal description length (MDL) discretization algorithm documented <a href="https://www.rdocumentation.org/packages/Biocomb/versions/0.4/topics/select.process" target="_blank">here</a>. After the ranking, the number of features are limited as set in options below. Performed on the training set balanced with SMOTE. Only features significant in DE are allowed.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="29" checked><span class="slider round"></span></label></td>
    <td>No: 29<br /><code>bounceR-full, bounceR-stability</code></td>
    <td>A component-wise-boosting-based algorithm selecting optimal features in multiple iterations of single feature-models construction. See the source <a href="https://github.com/STATWORX/bounceR" target="_blank">here</a>. <code>bounceR-stability</code> gets the most stable features. Wrapper methods implemented here leverage componentwise boosting as a weak learners.</td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="30" checked><span class="slider round"></span></label></td>
    <td>No: 30<br /><code>bounceR-full_SMOTE, bounceR-stability_SMOTE</code></td>
    <td>A component-wise-boosting-based algorithm selecting optimal features in multiple iterations of single feature-models construction. See the source <a href="https://github.com/STATWORX/bounceR" target="_blank">here</a>. <code>bounceR-stability</code> gets the most stable features. Wrapper methods implemented here leverage componentwise boosting as a weak learners. Performed on the training set balanced with SMOTE. </td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="31" checked><span class="slider round"></span></label></td>
    <td>No: 31<br /><code>bounceR-full_SIG, bounceR-stability_SIG</code></td>
    <td>A component-wise-boosting-based algorithm selecting optimal features in multiple iterations of single feature-models construction. See the source <a href="https://github.com/STATWORX/bounceR" target="_blank">here</a>. <code>bounceR-stability</code> gets the most stable features. Wrapper methods implemented here leverage componentwise boosting as a weak learners. Only features significant in DE are allowed. </td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="32" checked><span class="slider round"></span></label></td>
    <td>No: 32<br /><code>bounceR-full_SIGSMOTE, bounceR-stability_SIGSMOTE</code></td>
    <td>A component-wise-boosting-based algorithm selecting optimal features in multiple iterations of single feature-models construction. See the source <a href="https://github.com/STATWORX/bounceR" target="_blank">here</a>. <code>bounceR-stability</code> gets the most stable features. Wrapper methods implemented here leverage componentwise boosting as a weak learners. Only features significant in DE are allowed. Performed on the training set balanced with SMOTE. </td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="33" checked><span class="slider round"></span></label></td>
    <td>No: 33<br /><code>RandomForestRFE</code></td>
    <td>Recursively eliminates features from the feature space based on ranking from Random Forrest classifier (retrained woth resampling after each elimination). Details are available <a href="https://topepo.github.io/caret/recursive-feature-elimination.html#search" target="_blank">here</a>. </td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="34" checked><span class="slider round"></span></label></td>
    <td>No: 34<br /><code>RandomForestRFESMOTE</code></td>
    <td>Recursively eliminates features from the feature space based on ranking from Random Forrest classifier (retrained woth resampling after each elimination). Details are available <a href="https://topepo.github.io/caret/recursive-feature-elimination.html#search" target="_blank">here</a>. Performed on the training set balanced with SMOTE. </td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="35" checked><span class="slider round"></span></label></td>
    <td>No: 35<br /><code>RandomForestRFE_sig</code></td>
    <td>Recursively eliminates features from the feature space based on ranking from Random Forrest classifier (retrained woth resampling after each elimination). Details are available <a href="https://topepo.github.io/caret/recursive-feature-elimination.html#search" target="_blank">here</a>. Only features significant in DE are allowed.  </td>
</tr>

<tr>
<td><label class="switch"><input type="checkbox" name="method[]" value="36" checked><span class="slider round"></span></label></td>
    <td>No: 36<br /><code>RandomForestRFESMOTE_sig</code></td>
    <td>Recursively eliminates features from the feature space based on ranking from Random Forrest classifier (retrained woth resampling after each elimination). Details are available <a href="https://topepo.github.io/caret/recursive-feature-elimination.html#search" target="_blank">here</a>. Only features significant in DE are allowed. Performed on the training set balanced with SMOTE. </td>
</tr>










<tr>
    <td>Options:</td>
    <td colspan="2">
    <div class="form-group row">
    <div class="col-sm-7">
    <p><u>Prefered number of features</u><br />
<font size="1"><i>(some of the methods do not select features but rank them, how many features are acceptable for you?)</i></font></p>
    </div>
    <div class="col-sm-5">
      <input class="form-control" id="prefer_no_features" name="prefer_no_features" type="number" min="1" max="50" value="10" />
    </div>
  </div>
    <div class="form-group row">
    <div class="col-sm-7">
    <p><u>Timeout for selected methods</u><br />
<font size="1"><i>(max time for the method to run in seconds, if you do not want to wait the ethernity for the results in misconfigured pipeline)</i></font></p>
    </div>
    <div class="col-sm-5">
      <input class="form-control" id="timeout_sec" name="timeout_sec" type="number" min="0" max="2629743" value="86400" />
    </div>
  </div>
  <div class="form-group row">
    <div class="col-sm-7">
    <p><u>Maximum number of iterations</u><br />
<font size="1"><i>(maximum number of iterations in selected methods, setting this too high may results in very long comupting time)</i></font></p>
    </div>
    <div class="col-sm-5">
      <input class="form-control" id="max_iterations" name="max_iterations" type="number" min="1" max="50" value="10" />
    </div>
  </div>
    </td>
</tr>
</tbody>
</table>
<p>
<button type="submit" class="btn btn-success" value="Upload" name="submit" onclick="waitingDialog.show('Starting the analysis...');">
<i class="fas fa-clipboard-check"></i>&emsp;Start feature selection
</button></p>
</form>
        </div>
        </div>
<?php } else { ?>
  <div class="panel panel-success">
            <div class="panel-heading"><i class="fas fa-microscope"></i>&emsp;&emsp;Feature selection</div>
            <div class="panel-body">
              <p><h3>Final set of feature sets selected for further evaluation:</h3>
              <br /><font size="1">Notes: This table presents final formulas. <a href="https://kstawiski.github.io/miRNAselector/reference/ks.merge_formulas.html" target="_blank">The formulas with features more than the prefered number of features of features were trimmed (according to documentation).</a></font><br></p>
                <p><?php konsta_readcsv_formulas($target_dir . "featureselection_formulas_final.csv"); ?></p>
                <p><h4>Details:</h4>
                  
                  <table class="table">
                  <tr><td>All formulas selected by the methods:</td><td><a href="view.php?f=<?php echo $_GET['id']; ?>/featureselection_formulas_all.csv" class="btn btn-info" role="button" target="popup"
                        onclick="window.open('view.php?f=<?php echo $_GET['id']; ?>/featureselection_formulas_all.csv','popup','width=600,height=600'); return false;"><i class="fas fa-search-plus"></i> View</a>&emsp;<a href="/e/files/<?php echo $_GET['id']; ?>/featureselection_formulas_all.csv"  class="btn btn-warning" ><i class="fas fa-download"></i> Download</a></td></tr>
                   <tr><td>Final set of formulas selected by the methods:<br /><font size="1"><i>(formulas with more than prefered number of features were removed, classical selection methods are intact)</i></font><td><a href="view.php?f=<?php echo $_GET['id']; ?>/featureselection_formulas_final.csv" class="btn btn-info" role="button" target="popup"
                        onclick="window.open('view.php?f=<?php echo $_GET['id']; ?>/featureselection_formulas_final.csv','popup','width=600,height=600'); return false;"><i class="fas fa-search-plus"></i> View</a>&emsp;<a href="/e/files/<?php echo $_GET['id']; ?>/featureselection_formulas_final.csv"  class="btn btn-warning" ><i class="fas fa-download"></i> Download</a></td></tr>
                  <tr><td>Options:</td><td>
                  <a href="/e/edit/<?php echo $_GET['id']; ?>/temp/featureselection.log" class="btn btn-primary" role="button" target="popup"
                        onclick="window.open('/e/edit/<?php echo $_GET['id']; ?>/temp/featureselection.log','popup','width=600,height=600'); return false;"><i class="fas fa-history"></i> View log</a>&emsp;<a href="process.php?type=delete_fs&analysisid=<?php echo $_GET['id']; ?>" class="btn btn-danger" role="button" onclick="return confirm('Are you sure? This will delete all the data regarding your feature selection')"><i class="fas fa-trash"></i> Re-run selection</a>

                  </td></tr>
                      
                  </table>
                </p>

            </div>
</div>

<?php } ?>

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
</div>
  </body>

</html>


