<?php
$msg = "";
require_once 'class.formr.php';
$form = new Formr('bootstrap');

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
    } else {
        $msg = $msg . "There was an error uploading your file. ";
        file_put_contents('/miRNAselector/var_status.txt', "[0] INITIAL (UNCONFIGURED)");
    }
}
        
        break;

        
    case "cleandata":
        unlink("/miRNAselector/data.csv");
        $msg .= "Data file deleted. Please upload new file.";
        file_put_contents('/miRNAselector/var_status.txt', "[0] INITIAL (UNCONFIGURED)");
        break;
    
    
    case "configure":
        // Walidacja
        $weryfikacja = TRUE;
        
        if (strlen($form->post('project_name'))<3)
        { $msg .= " Project name has to be longer than 2 characters."; $weryfikacja = FALSE; }

        

        if($weryfikacja == FALSE) {
            $msg .= " → PLEASE SET UP A VALID VALUES AND TRY GENERATING CONFIG AGAIN!";
            $msg = urlencode($msg);
            header("Location: /?msg=" . $msg);
            die();
        }
        // Zapis do XML
        $msg .= print_r_xml($_POST);
        file_put_contents('/miRNAselector/config.xml', print_r_xml($_POST));

        $file = fopen('/miRNAselector/pipeline.R', 'w');
        fwrite($file, "library(miRNAselector)\n");
        fwrite($file, "library(knitr)\n");
        fwrite($file, "library(rmarkdown)\n");
        // Najpierw czy braki
        $ile_krokow = 0;

        // Preprocessing
        file_put_contents('/miRNAselector/var_input_format.txt', $form->post('input_format'));
        fwrite($file, "render('/miRNAselector/miRNAselector/templetes/result_preprocessing.Rmd', output_format = 'html_output', output_file = '/miRNAselector/result_preprocessing.html')\n");
        $ile_krokow = $ile_krokow + 1;

        // Najwazniejszy raport
        fwrite($file, "source('/miRNAselector/miRNAselector/templetes/featureselection.R')\n");
        $ile_krokow = $ile_krokow + 1;

        fwrite($file, "source('/miRNAselector/miRNAselector/templetes/benchmark.R')\n");
        $ile_krokow = $ile_krokow + 1;

        fwrite($file, "render('/miRNAselector/miRNAselector/templetes/result_raport.Rmd', output_format = 'html_output', output_file = '/miRNAselector/result_raport.html')\n");
        $ile_krokow = $ile_krokow + 1;
        
        file_put_contents('/miRNAselector/var_maxsteps.txt', $ile_krokow);
        
        fclose($file);
        //$msg .= file_get_contents("/miRNAselector/pipeline.R");
        //file_put_contents('/miRNAselector/var_status.txt', "[2] PROCESSING");
        break;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}  
if ($msg != "") { $msg = urlencode($msg); header("Location: /?msg=" . $msg); } else { header("Location: /"); }

?>