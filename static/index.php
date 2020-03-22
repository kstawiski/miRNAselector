<html>
<head>
<title>miRNAselector</title>
<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
<script
  src="https://code.jquery.com/jquery-3.4.1.min.js"
  integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="
  crossorigin="anonymous"></script>
<!-- Optional theme -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">

<!-- Latest compiled and minified JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
<meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content="">
    <meta name="author" content="">
	    <!-- Custom styles for this template -->
    <link href="starter-template.css" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.12.1/js/all.min.js" integrity="sha256-MAgcygDRahs+F/Nk5Vz387whB4kSK9NXlDN3w58LLq0=" crossorigin="anonymous"></script>
	<script src="js/cpufunctions.js" type="text/javascript"></script>
	<link rel="stylesheet" href="css/style.css" type="text/css" />
</head>
<body>
<nav class="navbar navbar-default navbar-fixed-top">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#">miRNAselector:</a>
        </div>
        <div id="navbar" class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li class="active"><a href="#"><i class="fas fa-home"></i> Start</a></li>
            <li><a href="e"><i class="fas fa-chart-bar"></i> Analysis, Report & Export</a></li>
          </ul>
        </div><!--/.nav-collapse -->
      </div>
    </nav>
              
              

    <div class="container">

      <div class="starter-template">
		<img src="logo.png" width="80%" />
      </div>
              
              
              <h2><i class="fas fa-info"></i> Introduction</h2>
              <p>Welcome to <b>miRNAselector</b> - the software intended to find the best biomarker signiture based on NGS and qPCR data.</p>
              
			<h2><i class="fas fa-upload"></i> Upload your data</h2> 
              <p><pre><?php system("ps -ef"); ?></pre></p>
              <p><pre><?php system("df -h"); ?></pre></p>
			  
			  
			  
			  
			  
			  
			  
			  
			  
			  
			  
			  
			  
			  
			  
			  <div class="starter-template">
		<h2><i class="fas fa-monitor-heart-rate"></i> System Monitor</h2>
		<div id="tabs" class="tabbg" style="border: 1px solid grey">
            <ul>
                <li><a href="#tabs-3">Overview</a></li >
                <li><a href="#tabs-1">CPU Monitor</a></li>
                <li><a href="#tabs-2">RAM Monitor</a></li>
                <li><a href="#tabs-4">GPU Monitor</a></li>
            </ul>

            <div id="tabs-1">
                <div class="grid half">&nbsp;
                    <div class="left">
                        <b>&nbsp;CPU Usage:</b>&nbsp;
                    </div>
                    <div id="cpu" class="left">&nbsp;</div>
                    <div class="left">%</div>
                    <?php
                        $width = 5;
                        for($i = 0; $i < 40; $i++){
                            print("<div id='cpu$i' class='big bar' style='left: ".$width."px;'>&nbsp;</div>  ");
                            $width = $width + 17;
                        }
                        ?>
                </div>

                <div style="height:18px;">&nbsp;</div>

                <div class="grid half">&nbsp;
                    <div class="left">
                        <b>&nbsp;CPU Temperature:</b>&nbsp;
                    </div>
                    <div id="cputemp" class="left">&nbsp;</div>
                    <div class="left">°C</div>
                    <?php
                    $width = 5;
                    for($i = 0; $i < 40; $i++){
                        print("<div id='cputemp$i' class='big bar' style='left: ".$width."px;'>&nbsp;</div>  ");
                        $width = $width + 17;
                    }
                    ?>
                </div>
            </div>

            <div id="tabs-2">
                <div class="grid full">&nbsp;
                    <div class="left">
                        <b>&nbsp;RAM Usage:</b>&nbsp;
                    </div>
                    <div id="ram" class="left">&nbsp;
                    </div><div class="left">%</div>
                    <?php
                        $width = 5;
                        for($i = 0; $i < 40; $i++){
                            print("<div id='ram$i'  class='big bar' style = 'left: ".$width."px;'>&nbsp;</div> ");
                            $width = $width + 17;
                        }
                    ?>
                </div>
            </div>

            <div id="tabs-3">
                <div class="grid half">&nbsp;
                    <div class="left">
                        <b>&nbsp;CPU Usage:</b>&nbsp;
                    </div>
                    <div id="cpuO" class="left">&nbsp;
                    </div><div class="left">%</div>
                    <?php
                        $width = 5;
                        for($i = 0; $i < 40; $i++){
                            print("<div id='cpuO$i' class='small bar' style = 'left: ".$width."px;'>&nbsp;</div>  ");
                            $width = $width + 17;
                        }
                    ?>
                </div>

                <div style="height:18px;">&nbsp;</div>

                <div class="grid half">&nbsp;
                    <div class="left"><b>&nbsp;RAM Usage:</b>&nbsp;</div><div id="ramO" class="left">&nbsp;</div><div class="left">%</div>
                    <?php
                        $width = 5;
                        for($i = 0; $i < 40; $i++){
                            print("<div id='ramO$i' class='small bar' style = 'left: ".$width."px;'>&nbsp;</div> ");
                            $width = $width + 17;
                        }
                    ?>
                </div>
            </div>

            <div id="tabs-4">
                <div class="grid full">&nbsp;
                    <div class="left">
                        <b>&nbsp;GPU Temperatur:</b>&nbsp;
                    </div>
                    <div id="gputemp" class="left">&nbsp;
                    </div><div class="left">°C</div>
                    <?php
                    $width = 5;
                    for($i = 0; $i < 40; $i++){
                        print("<div id='gputemp$i'  class='big bar' style = 'left: ".$width."px;'>&nbsp;</div> ");
                        $width = $width + 17;
                    }
                    ?>
                </div>
            </div>
	  </div>
      </div>
			  
			  
			  
			  
			  
              </div>
	 
              
              
    
              
              
              
              
              <hr>
<footer class="footer">
      <div class="container">
        <span class="text-muted">miRNAselector by Konrad Stawiski and Marcin Kaszkowiak | Contact: konrad@konsta.com.pl | WWW: <a href="https://biostat.umed.pl">www.biostat.umed.pl</a></span>
      </div>
    </footer>
    </div><!-- /.container -->
	
	
</body>
</html>