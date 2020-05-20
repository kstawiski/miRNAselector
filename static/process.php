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
        exec('screen -dmS mirnaselector-'.$step_name.' /miRNAselector/miRNAselector/docker/'. $step_name . '.sh');
        sleep(2); // Czas, zeby zaczal pisac log.
        if (shell_exec('ps -ef | grep -v grep | grep mirnaselector-'.$step_name.' | wc -l')>0) {
        file_put_contents('/miRNAselector/var_status.txt', "[1] PREPROCESSING RUNNING"); $msg = "Step <code>".$step_name."</code> is running..."; } else {
            $msg = "Something is wrong with <code>".$step_name."</code> :( Please check the logs in <code>/miRNAselector</code> directory for clarification.";        }
        $msg = urlencode($msg);
        header("Location: /?msg=" . $msg);
        die();
    break;


    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
}  
if ($msg != "") { $msg = urlencode($msg); header("Location: /?msg=" . $msg); } else { header("Location: /"); }

?>