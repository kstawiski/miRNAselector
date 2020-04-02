<?php
$msg = "";
require_once 'class.formr.php';
$form = new Formr('bootstrap');
switch($_GET['type'])
{
    case "upload":
        $target_dir = "/root/miRNAselector/";
        $target_file = $target_dir . "data.csv";
        $uploadOk = 1;
        $imageFileType = strtolower(pathinfo($target_file,PATHINFO_EXTENSION));
        
        
        $mimes = array('application/vnd.ms-excel','text/plain','text/csv','text/tsv');
        if(in_array($_FILES['fileToUpload']['type'],$mimes)){
        $uploadOk = 1;
        } else { $uploadOk = 0; $msg .= "Your upload file is not a correct csv-formatted file. "; file_put_contents('/root/miRNAselector/var_status.txt', "[0] INITIAL (UNCONFIGURED)"); }
        
        // Check if $uploadOk is set to 0 by an error
if ($uploadOk == 0) {
    $msg = $msg . "Your file was not uploaded. Please try again. ";
// if everything is ok, try to upload file
} else {
    if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
        $msg = "The file `". basename( $_FILES["fileToUpload"]["name"]). "` has been uploaded. It was saved as `data.csv` in the main project directory. You can continue with formal checking of file and starting the pipeline.";
        file_put_contents('/root/miRNAselector/var_status.txt', "[1] DATA UPLOADED (UNCONFIGURED)");
    } else {
        $msg = $msg . "There was an error uploading your file. ";
        file_put_contents('/root/miRNAselector/var_status.txt', "[0] INITIAL (UNCONFIGURED)");
    }
}
        
        break;

        
    case "cleandata":
        unlink("/root/miRNAselector/data.csv");
        $msg .= "Data file deleted. Please upload new file.";
        file_put_contents('/root/miRNAselector/var_status.txt', "[0] INITIAL (UNCONFIGURED)");
        break;
    
    
    case "configure":
        $file = fopen('/root/miRNAselector/pipeline.R', 'w');
        fwrite($file, "library(miRNAselector)\n");
        fwrite($file, "library(knitr)\n");
        fwrite($file, "library(rmarkdown)\n");
        // Najpierw czy braki
        $ile_krokow = 0;
        if($form->post('missing_imput') != "") { 
            file_put_contents('/root/miRNAselector/var_missing_imput.txt', $form->post('missing_imput'));
            fwrite($file, "render('/root/miRNAselector/miRNAselector/templetes/result_missing.Rmd', output_format = 'html', output_file = '/root/miRNAselector/result_missing.html')\n");
            $ile_krokow = $ile_krokow + 1;
        }

        // Czy batch correct
        if($form->post('correct_batch') != "") { 
            file_put_contents('/root/miRNAselector/var_correct_batch.txt', $form->post('correct_batch'));
            fwrite($file, "render('/root/miRNAselector/miRNAselector/templetes/result_correct_batch.Rmd', output_format = 'html', output_file = '/root/miRNAselector/result_correct_batch.html')\n");
            $ile_krokow = $ile_krokow + 1;
        }

        // Czy wymaga normalizacji
        file_put_contents('/root/miRNAselector/var_input_format.txt', $form->post('input_format'));
        if($form->post('input_format') == "counts" || $form->post('input_format') == "countswithoutfilter") {
            fwrite($file, "render('/root/miRNAselector/miRNAselector/templetes/result_toTPM.Rmd', output_format = 'html', output_file = '/root/miRNAselector/result_toTPM.html')\n");
            $ile_krokow = $ile_krokow + 1;
        }

        // Najwazniejszy raport
        fwrite($file, "source('/root/miRNAselector/miRNAselector/templetes/featureselection.R')\n");
        $ile_krokow = $ile_krokow + 1;

        fwrite($file, "source('/root/miRNAselector/miRNAselector/templetes/benchmark.R')\n");
        $ile_krokow = $ile_krokow + 1;

        fwrite($file, "render('/root/miRNAselector/miRNAselector/templetes/result_raport.Rmd', output_format = 'html', output_file = '/root/miRNAselector/result_raport.html')\n");
        $ile_krokow = $ile_krokow + 1;
        
        file_put_contents('/root/miRNAselector/var_maxsteps.txt', $ile_krokow);
        
        fclose($file);
        $msg .= file_get_contents("/root/miRNAselector/pipeline.R");
        //file_put_contents('/root/miRNAselector/var_status.txt', "[2] PROCESSING");
        break;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}  
if ($msg != "") { $msg = urlencode($msg); header("Location: /?msg=" . $msg); } else { header("Location: /" . $msg); }

?>