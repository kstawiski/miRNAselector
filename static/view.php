<?php
     
    //------------------------------------------------
    //Configuration
    //
    $fileName = "/miRNAselector/" . $_GET['f']; //CSV file location
    $delimiter = ","; //CSV delimiter character: , ; /t
    $enclosure = '"'; //CSV enclosure character: " ' 
    $password = ''; //Optional to prevent abuse. If set to [your_password] will require the &Password=[your_password] GET parameter to open the file
    $ignorePreHeader = 3; //Number of characters to ignore before the table header. Windows UTF-8 BOM has 3 characters.
    //------------------------------------------------
     
    //Variable initialization
    $logLines = array();
    $tableOutput = "<b>No data loaded</b>";
     
    //Verify the password (if set)
    if($_GET["Password"] === $password || $password === ""){
     
    		if(file_exists($fileName)){ // File exists
     
    		// Reads lines of file to array
    		$fileLines = file($fileName, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
     
    		//Not Empty file
    		if($fileLines !== array()){
     
    			//Extract the existing header from the file
    			$lineHeader = array_shift($fileLines);
    			$logOriginalHeader = array_map('trim', str_getcsv(substr($lineHeader,$ignorePreHeader), $delimiter, $enclosure));
     
    			//Process the file only if the system could find a valid header
    			if(count($logOriginalHeader) > 0) {			
    				//Open the table tag
    				$tableOutput="<TABLE class='table' id='table' name='table'>";
     
    				//Print the table header
    				$tableOutput.="<THEAD><TR style='background-color: lightgray;text-align:center;'>";
                    $tableOutput.="<TD><B>Row</B></TD>"; 
                    $ihead = 0;
    				foreach ($logOriginalHeader as $field) {
                        $tableOutput.="<TD><B>".$field."</B></TD>"; //Add the columns
                        if (++$ihead == 100) break;   // Nie więcej niż 100 kolumn.
                    }
    				$tableOutput.="</TR></THEAD>";
     
                    $tableOutput.="<TBODY>";
    				//Get each line of the array and print the table files
    				$countLines = 0;
    				foreach ($fileLines as $line) {
    					if(trim($line) !== ''){ //Remove blank lines
                                $countLines++;
                                if ($countLines == 1000) break; // Nie więcej niż 1000 przypadków.
    							$arrayFields = array_map('trim', str_getcsv($line, $delimiter, $enclosure)); //Convert line to array
    							$tableOutput.="<TR><TD style='background-color: lightgray;'>".$countLines."</TD>";
                                $ihead = 0;
                                foreach ($arrayFields as $field) {
                                    $tableOutput.="<TD>".$field."</TD>"; //Add the columns
                                    if (++$ihead == 100) break; // Nie więcej niż 100 kolumn.
                                }
    							$tableOutput.="</TR>";
    						}
    				}
     
    				//Close the table tag
                    $tableOutput.="</TBODY>";
    				$tableOutput.="</TABLE>";
    			}
    			else $tableOutput = "<b>Invalid data format</b>";
    		}
    		else $tableOutput = "<b>Empty file</b>";
    	}
    	else $tableOutput = "<b>File not found</b>";
    }
    else $tableOutput = "<b>Invalid password.</b> Enter the password using this URL format: ".$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI']."?Password=<b>your_password</b>";
     
    ?>
    <!DOCTYPE html>
    <html>
    <head>
    <title>miRNAselector - CSV viewer</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
    integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous" />
    <script src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="
    crossorigin="anonymous"></script>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css"
    integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous" />
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
    integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.12.1/js/all.min.js" integrity="sha256-MAgcygDRahs+F/Nk5Vz387whB4kSK9NXlDN3w58LLq0=" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-1.8.3.min.js" type="text/javascript"></script>
    <script src="https://code.jquery.com/ui/1.9.2/jquery-ui.js" type="text/javascript"></script>
        
    <script src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.min.js" type="text/javascript"></script>
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.min.css" crossorigin="anonymous" /> 
        <script src="https://code.jquery.com/jquery-3.3.1.js
<script src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.min.js" type="text/javascript"></script>
<script src="https://cdn.datatables.net/buttons/1.6.1/js/dataTables.buttons.min.js" type="text/javascript"></script>
<script src="https://cdn.datatables.net/buttons/1.6.1/js/buttons.flash.min.js" type="text/javascript"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.1.3/jszip.min.js" type="text/javascript"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.53/pdfmake.min.js" type="text/javascript"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.53/vfs_fonts.js" type="text/javascript"></script>
<script src="https://cdn.datatables.net/buttons/1.6.1/js/buttons.html5.min.js" type="text/javascript"></script>
<script src="https://cdn.datatables.net/buttons/1.6.1/js/buttons.print.min.js" type="text/javascript"></script>
        <script>
        $(document).ready( function () {
    $('#table').DataTable({
    dom: 'Bfrtip',
        buttons: [
            'copy', 'csv', 'excel', 'pdf', 'print'
        ],
        "pageLength": 50
    });
} );
        </script>
    </head>
    <body>
<?=$tableOutput ?>
    </body>
    </html>