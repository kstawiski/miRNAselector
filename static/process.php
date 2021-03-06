<?php
$msg = "";
require_once 'class.formr.php';
$form = new Formr('bootstrap');
putenv("PATH=/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin");

/* print the contents of a url */
function print_r_xml($arr,$wrapper = 'data',$cycle = 1)
{
	//useful vars
	$new_line = "\n";

	//start building content
	if($cycle == 1) { $output = '<?xml version="1.0" encoding="UTF-8" ?>'.$new_line; }
	$output.= tabify($cycle - 1).'<'.$wrapper.'>'.$new_line;
	foreach($arr as $key => $val)
	{
		if(!is_array($val))
		{
			$output.= tabify($cycle).'<'.htmlspecialchars($key).'>'.$val.'</'.htmlspecialchars($key).'>'.$new_line;
		}
		else
		{
			$output.= print_r_xml($val,$key,$cycle + 1).$new_line;
		}
	}
	$output.= tabify($cycle - 1).'</'.$wrapper.'>';

	//return the value
	return $output;
}

/* tabify */
function tabify($num_tabs)
{
	for($x = 1; $x <= $num_tabs; $x++) { $return.= "\t"; }
	return $return;
}

/* co jesli bedzie matematyczny */
function matematyczny_input($ma) {
    if(preg_match('/(\d+)(?:\s*)([\+\-\*\/])(?:\s*)(\d+)/', $ma, $matches) !== FALSE){
        $operator = $matches[2];
    
        switch($operator){
            case '+':
                $p = $matches[1] + $matches[3];
                break;
            case '-':
                $p = $matches[1] - $matches[3];
                break;
            case '*':
                $p = $matches[1] * $matches[3];
                break;
            case '/':
                $p = $matches[1] / $matches[3];
                break;
        }
    
        return $p;
    } else {  return $ma; }
}

switch($_GET['type'])
{
    
    case "new_analysis":
        $analysis_id = hash("sha1", uniqid("miRNAselector",TRUE));
        $target_dir = "/miRNAselector/" . $analysis_id . "/";
        
        $uploadOk = 1;
        $imageFileType = strtolower(pathinfo($target_file,PATHINFO_EXTENSION));
        $mimes = array('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet','application/vnd.ms-excel','text/plain','text/csv','text/tsv');
        if(in_array($_FILES['fileToUpload']['type'],$mimes)) {
            $uploadOk = 1;
        } else {
        $uploadOk = 0; $msg .= "Your upload file is not a correct csv-formatted oraz Excel file. Please try again."; $msg = urlencode($msg); header("Location: /start.php?msg=" . $msg); die();
        }
        
        $file_extension = explode('.',$_FILES["fileToUpload"]["name"]);
        $file_extension = strtolower(end($file_extension));
        $accepted_formate = array('csv');
        if(in_array($file_extension,$accepted_formate))
        {
            $upload_type = "csv";
            $target_file = $target_dir . "data.csv";
            $uploadOk = 1;
        }

        $accepted_formate = array('xlsx');
        if(in_array($file_extension,$accepted_formate))
        {
            $upload_type = "xlsx";
            $target_file = $target_dir . "data.xlsx";
            $uploadOk = 1;
        }

        $accepted_formate = array('csv','xlsx');
        if(!in_array($file_extension,$accepted_formate))
        {
            $uploadOk = 0; $msg .= "The file has to have xlsx or csv extension. "; $msg = urlencode($msg); header("Location: /start.php?msg=" . $msg); die();
        }
        
            // Check if $uploadOk is set to 0 by an error
    if ($uploadOk == 0) {
        $msg = $msg . "Your file was not uploaded. Please try again. "; header("Location: /start.php?msg=" . $msg); die();
    // if everything is ok, try to upload file
    } else {
        exec("mkdir " . $target_dir);
        file_put_contents($target_dir . '/var_type.txt', $_POST['type']);
        if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
        $msg = "The file `". basename( $_FILES["fileToUpload"]["name"]). "` has been uploaded. It was saved in the main project directory. You can continue with formal checking of file and starting the pipeline.";
       
        exec("cp /miRNAselector/miRNAselector/docker/1_formalcheckcsv.R " . $target_dir . "formalcheckcsv.R");
        exec("cp /miRNAselector/miRNAselector/docker/own_analysis.R " . $target_dir . "own_analysis.R");
        exec("cd " . $target_dir . " && Rscript formalcheckcsv.R 2>&1 | tee -a " . $target_dir . "initial_check.txt");
        header("Location: /analysis.php?id=" . $analysis_id); die();
    } else {
        $msg = $msg . "There was an error uploading your file. ";
        header("Location: /start.php?msg=" . $msg); die();
    }
    }
        
        break;
    

        case "analysis_de":
            session_start();
            $target_dir = "/miRNAselector/" . $_SESSION["analysis_id"] . "/";
            file_put_contents($target_dir . 'var_demode.txt', $_POST['demode']);
            exec("cp /miRNAselector/miRNAselector/templetes/DE.rmd " . $target_dir . "DE.rmd");
            exec("cd " . $target_dir . " && Rscript -e \"knitr::knit2html('DE.rmd')\" 2>&1 | tee -a " . $target_dir . "log.txt");
            header("Location: /analysis.php?id=" . $_SESSION["analysis_id"]); die();
        break;

    // Feature selection invoked by analysis.php
    case "new_fs":
        // Sanity check
        $analysis_id = $_POST['analysisid'];
        $target_dir = "/miRNAselector/" . $analysis_id . "/";
        if (!file_exists($target_dir)) { die('Analysis not found.'); }

        // Debug
        ob_flush();
        ob_start();
        var_dump($_POST);
        file_put_contents($target_dir . '/debug.txt', ob_get_flush());

        // Save selected methods as csv
        $metody = "m";
        foreach($_POST['method'] as $value){  $metody .= PHP_EOL . $value; }
        file_put_contents($target_dir . '/selected_methods.csv', $metody);

        
        // Save additional vars as files
        file_put_contents($target_dir . '/var_timeout_sec.txt', $_POST['timeout_sec']);
        file_put_contents($target_dir . '/var_prefer_no_features.txt', $_POST['prefer_no_features']);
        file_put_contents($target_dir . '/var_max_iterations.txt', $_POST['max_iterations']);

        // Starting fs
        exec("cp /miRNAselector/miRNAselector/docker/feature_selection.R " . $target_dir . "feature_selection.R");
        exec("cd " . $target_dir . " && screen -dmS mirnaselector-". $analysis_id ." Rscript feature_selection.R");
        sleep(3); // Wait to start writing log.

        // Redirect to analysis
        header("Location: /analysis.php?id=" . $analysis_id); die();
    break;
    
    case "delete_fs":
        // Sanity check
        $analysis_id = $_GET['analysisid'];
        $target_dir = "/miRNAselector/" . $analysis_id . "/";
        if (!file_exists($target_dir)) { die('Analysis not found.'); }

        $dirPath = $target_dir . "temp";
        if (! is_dir($dirPath)) {
            throw new InvalidArgumentException("$dirPath must be a directory");
        }
        if (substr($dirPath, strlen($dirPath) - 1, 1) != '/') {
            $dirPath .= '/';
        }
        $files = glob($dirPath . '*', GLOB_MARK);
        foreach ($files as $file) {
            if (is_dir($file)) {
                self::deleteDir($file);
            } else {
                unlink($file);
            }
        }
        rmdir($dirPath);
        unlink($target_dir . "featureselection_formulas_all.csv");

        // Redirect to analysis
        header("Location: /analysis.php?id=" . $analysis_id); die();
    break;

    case "delete_fs2":
        // Sanity check
        $analysis_id = $_GET['analysisid'];
        $target_dir = "/miRNAselector/" . $analysis_id . "/";
        if (!file_exists($target_dir)) { die('Analysis not found.'); }

        // $dirPath = $target_dir . "temp";
        // if (! is_dir($dirPath)) {
        //     throw new InvalidArgumentException("$dirPath must be a directory");
        // }
        // if (substr($dirPath, strlen($dirPath) - 1, 1) != '/') {
        //     $dirPath .= '/';
        // }
        // $files = glob($dirPath . '*', GLOB_MARK);
        // foreach ($files as $file) {
        //     if (is_dir($file)) {
        //         self::deleteDir($file);
        //     } else {
        //         unlink($file);
        //     }
        // }
        // rmdir($dirPath);
        unlink($target_dir . "featureselection_formulas_all.csv");

        // Redirect to analysis
        header("Location: /analysis.php?id=" . $analysis_id); die();
    break;
    
    case "recover_fs":
        // Sanity check
        $analysis_id = $_GET['analysisid'];
        $target_dir = "/miRNAselector/" . $analysis_id . "/";
        if (!file_exists($target_dir)) { die('Analysis not found.'); }

        // Starting fs
        exec("cp /miRNAselector/miRNAselector/docker/recover_fs.R " . $target_dir . "recover_fs.R");
        exec("cp /miRNAselector/miRNAselector/docker/best_signiture.Rmd " . $target_dir . "best_signiture.Rmd");
        exec("cd " . $target_dir . " && screen -dmS mirnaselector-". $analysis_id ." Rscript recover_fs.R");
        sleep(3); // Wait to start writing log.

        // Redirect to analysis
        header("Location: /analysis.php?id=" . $analysis_id); die();
    break;
    
    // Benchmarking invoked by analysis.php
    case "new_benchmark":
        // Sanity check
        $analysis_id = $_POST['analysisid'];
        $target_dir = "/miRNAselector/" . $analysis_id . "/";
        if (!file_exists($target_dir)) { die('Analysis not found.'); }

        // Debug
        ob_flush();
        ob_start();
        var_dump($_POST);
        file_put_contents($target_dir . '/debug.txt', ob_get_flush());

        // Save selected methods as csv
        $metody = "m";
        foreach($_POST['method'] as $value){  $metody .= PHP_EOL . $value; }
        file_put_contents($target_dir . '/selected_benchmark.csv', $metody);

        // Save additional vars as files
        file_put_contents($target_dir . '/var_mxnet.txt', $_POST['mxnet']);
        file_put_contents($target_dir . '/var_search_iters_mxnet.txt', $_POST['search_iters_mxnet']);
        file_put_contents($target_dir . '/var_search_iters.txt', $_POST['search_iter']);
        file_put_contents($target_dir . '/var_holdout.txt', $_POST['holdout']);
        file_put_contents($target_dir . '/var_holdout.txt', $_POST['holdout']);

        // Starting benchmark
        exec("cp /miRNAselector/miRNAselector/docker/benchmark.R " . $target_dir . "benchmark.R");
        exec("cp /miRNAselector/miRNAselector/docker/best_signiture.Rmd " . $target_dir . "best_signiture.Rmd");
        exec("cd " . $target_dir . " && screen -dmS mirnaselector-". $analysis_id ." Rscript benchmark.R");
        sleep(3); // Wait to start writing log.

        // Redirect to analysis
        header("Location: /analysis.php?id=" . $analysis_id); die();
    break;

    case "select_in_dataset":
        // Sanity check
        $analysis_id = $_GET['id'];
        $target_dir = "/miRNAselector/" . $analysis_id . "/";
        if (!file_exists($target_dir)) { die('Analysis not found.'); }
        
        // Add vars
        $method = $_GET['method'];
        $filename = $target_dir . $method . ".csv";

        $skrypt = 'library(miRNAselector); miRNAs = ks.get_miRNAs_from_benchmark(benchmark_csv = "benchmark.csv", method = "' . $method . '"); library(dplyr); library(data.table); dane = fread("mixed.csv"); dane2 = dplyr::select(dane, -starts_with("hsa"), miRNAs); fwrite(dane2, "'. $filename .'");';
        exec("cd " . $target_dir . " && Rscript -e '" . $skrypt . "'");
        
        //Get file type and set it as Content Type
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        header('Content-Type: ' . finfo_file($finfo, $filename));
        finfo_close($finfo);

        //Use Content-Disposition: attachment to specify the filename
        header('Content-Disposition: attachment; filename='.basename($filename));

        //No cache
        header('Expires: 0');
        header('Cache-Control: must-revalidate');
        header('Pragma: public');

        //Define file size
        header('Content-Length: ' . filesize($filename));

        ob_clean();
        flush();
        readfile($filename);
        exit;
    break;
    

    case "best_signiture_render":
        // Sanity check
        $analysis_id = $_GET['id'];
        $target_dir = "/miRNAselector/" . $analysis_id . "/";
        if (!file_exists($target_dir)) { die('Analysis not found.'); }

        $skrypt = 'rmarkdown::render("best_signiture.Rmd")';
        exec("cd " . $target_dir . " && Rscript -e '" . $skrypt . "'");
        
        header("Location: /analysis.php?id=" . $analysis_id); die();
    break;
    
    case "delete_benchmark":
        // Sanity check
        $analysis_id = $_GET['analysisid'];
        $target_dir = "/miRNAselector/" . $analysis_id . "/";
        if (!file_exists($target_dir)) { die('Analysis not found.'); }

        // $dirPath = $target_dir . "temp";
        // if (! is_dir($dirPath)) {
        //     throw new InvalidArgumentException("$dirPath must be a directory");
        // }
        // if (substr($dirPath, strlen($dirPath) - 1, 1) != '/') {
        //     $dirPath .= '/';
        // }
        // $files = glob($dirPath . '*', GLOB_MARK);
        // foreach ($files as $file) {
        //     if (is_dir($file)) {
        //         self::deleteDir($file);
        //     } else {
        //         unlink($file);
        //     }
        // }
        // rmdir($dirPath);
        unlink($target_dir . "benchmark.csv");

        // Redirect to analysis
        header("Location: /analysis.php?id=" . $analysis_id); die();
    break;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // STARE FUNKCJE:
    case "upload":
        $target_dir = "/miRNAselector/";
        $target_file = $target_dir . "data.csv";
        $uploadOk = 1;
        $imageFileType = strtolower(pathinfo($target_file,PATHINFO_EXTENSION));
        
        
        $mimes = array('application/vnd.ms-excel','text/plain','text/csv','text/tsv');
        if(in_array($_FILES['fileToUpload']['type'],$mimes)){
        $uploadOk = 1;
        } else { $uploadOk = 0; $msg .= "Your upload file is not a correct csv-formatted file. "; file_put_contents('/miRNAselector/var_status.txt', "[0] INITIAL (UNCONFIGURED)"); }
        
            // Check if $uploadOk is set to 0 by an error
    if ($uploadOk == 0) {
        $msg = $msg . "Your file was not uploaded. Please try again. ";
    // if everything is ok, try to upload file
    } else {
    if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
        $msg = "The file `". basename( $_FILES["fileToUpload"]["name"]). "` has been uploaded. It was saved as `data.csv` in the main project directory. You can continue with formal checking of file and starting the pipeline.";
        file_put_contents('/miRNAselector/var_status.txt', "[1] DATA UPLOADED (UNCONFIGURED)");
        exec("Rscript /miRNAselector/miRNAselector/docker/1_formalcheckcsv.R 2>&1 | tee -a /miRNAselector/initial_check.txt");
    } else {
        $msg = $msg . "There was an error uploading your file. ";
        file_put_contents('/miRNAselector/var_status.txt', "[0] INITIAL (UNCONFIGURED)");
    }
    }
        
        break;

        
    case "cleandata":
        if(file_exists("/miRNAselector/data.csv")) { unlink("/miRNAselector/data.csv"); }
        if(file_exists("/miRNAselector/data_start.csv")) { unlink("/miRNAselector/data_start.csv"); }
        if(file_exists("/miRNAselector/initial_check.txt")) { unlink("/miRNAselector/initial_check.txt"); }
        if(file_exists("/miRNAselector/config.xml")) { unlink("/miRNAselector/config.xml"); }
        $mask = '/miRNAselector/var_*.*';
        array_map('unlink', glob($mask));
        $mask = '/miRNAselector/result_*.*';
        array_map('unlink', glob($mask));
        $msg .= "Data file deleted. Please upload new file.";
        file_put_contents('/miRNAselector/var_status.txt', "[0] INITIAL (UNCONFIGURED)");
        break;
    

    case "init_update":
        if (file_exists("/update.log")) { unlink('/update.log'); }
        exec('chmod 777 /miRNAselector/miRNAselector/docker/software_update.sh');
        exec('screen -dmS mirnaselector-updater /miRNAselector/miRNAselector/docker/software_update.sh');
        sleep(3); // Czas, zeby zaczal pisac log.
        header("Location: /software_update.php");
        die();
    break;

    case "init_preprocessing":
        $step_name = "1_preprocessing";
        
        // Walidacja:
        $weryfikacja = TRUE;
            
        if (strlen($form->post('project_name'))<3)
        { $msg .= " Project name has to be longer than 2 characters."; $weryfikacja = FALSE; }

        

        if($weryfikacja == FALSE) {
            $msg .= " → PLEASE SET UP A VALID VALUES AND TRY GENERATING CONFIG AGAIN!";
            $msg = urlencode($msg);
            header("Location: /?msg=" . $msg);
            die();
        }
        // Zapis do XML:
        $msg .= print_r_xml($_POST);
        file_put_contents('/miRNAselector/'. $step_name . '.xml', print_r_xml($_POST));
        
        if (file_exists("/miRNAselector/". $step_name .".log")) { unlink('/miRNAselector/'. $step_name . '.log'); }
        exec('/bin/cp /miRNAselector/miRNAselector/templetes/'. $step_name .'.rmd /miRNAselector/' . $step_name . '.Rmd '); // PAMIETAC ZEBY ZMIENIEC TEMPLETE!!!
        exec('screen -dmS mirnaselector-task /miRNAselector/miRNAselector/docker/'. $step_name . '.sh');
        sleep(3); // Czas, zeby zaczal pisac log.
        header("Location: /inprogress.php");
        die();
    break;

    case "cancel":
        exec("kill -9 " . $_GET['pid']);
        $msg .= "The running process was interrupted. Configure and run it again.";
        header("Location: /?msg=" . $msg);
        die();
    break;

    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
}  
if ($msg != "") { $msg = urlencode($msg); header("Location: /?msg=" . $msg); } else { header("Location: /"); }

?>