<?php
$msg = "";
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}  
if ($msg != "") { $msg = urlencode($msg); header("Location: /?msg=" . $msg); } else { header("Location: /" . $msg); }

?>