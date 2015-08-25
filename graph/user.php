<!DOCTYPE html>
<html> 
    <head>
        <title>Monitoring - @USER@</title>
        <link rel="icon" type="image/png" href="favicon.png">
		<link rel="shortcut icon" type="image/x-icon" href="favicon.ico">
		<link rel="stylesheet" type="text/css" href="./style.css">
        <meta charset="utf-8" />
        <!-- Bootstrap -->
        <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">
        <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap-theme.min.css">
		<script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
        
        <!-- CSS Perso -->
        <link rel="stylesheet" href="./style.css">
        <link href='https://fonts.googleapis.com/css?family=Ubuntu' rel='stylesheet' type='text/css'>

        <!-- Scripts -->
        <script src="//ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
        <script src="//code.jquery.com/jquery-1.10.2.js"></script>
        <script src="//code.jquery.com/ui/1.10.4/jquery-ui.js"></script>
        <script src="./nav.js"></script>
    </head>

    <body>
        <!-- NavBar -->
        <nav class="navbar navbar-default navbar-fixed-top" role="navigation">
            <div class="container-fluid">
                <!-- Brand and toggle get grouped for better mobile display -->
                <div class="navbar-header">
                    <a class="navbar-brand" href=""><b>Monitoring</b></a>
                </div>
                <!-- Collect the nav links, forms, and other content for toggling -->
                <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
                    <ul class="nav navbar-nav">
                        <li><a href="../seedbox-manager/">Seedbox-Manager</a></li>
                        <li><a href="../rutorrent/">ruTorrent</a></li>
                    </ul>
                </div><!-- /.navbar-collapse -->
            </div><!-- /.container-fluid -->
        </nav>
        
        <!-- Graphs -->
        <div class="imgcontainer">
            <ul id="output_1" class="stats">
                    <ul class="stats_li"><li class="stats_li" id="name_1"><h1>@USER@</h1></li></ul><ul class="stats_li_adv"><li class="stats_li_adv" id="name_adv"><h2>↑ Cliquer pour les détails ↑</h2></li></ul><img src="../graph/img/@RTOM@_spdd-day.png"><img src="../graph/img/@RTOM@_peers-day.png"><img src="../graph/img/@RTOM@_mem-day.png">
            </ul>
            <ul  id="outputa_1" class="stats1_det" style="display:none">
                    <ul class="stats_det"><li class="stats_det">Vitesses</li></ul><ul class="stats_det_nav"><li class="stats_det_nav" id="adv_1_det">Par jour</li><li class="stats_det_nav" id="adv_2_det">Par semaine</li><li class="stats_det_nav" id="adv_3_det">Par mois</li></ul><img src="../graph/img/@RTOM@_spdd-day.png"><img src="../graph/img/@RTOM@_spdd-week.png"><img src="../graph/img/@RTOM@_spdd-month.png">
            </ul>
            <ul id="outputb_1" class="stats1_det" style="display:none">
                    <ul class="stats_det"><li class="stats_det">Nombre de pairs</li></ul><ul class="stats_det_nav"><li class="stats_det_nav" id="adv_1_det">Par jour</li><li class="stats_det_nav" id="adv_2_det">Par semaine</li><li class="stats_det_nav" id="adv_3_det">Par mois</li></ul><img src="../graph/img/@RTOM@_peers-day.png"><img src="../graph/img/@RTOM@_peers-week.png"><img src="../graph/img/@RTOM@_peers-month.png">
            </ul>
            <ul id="outputc_1" class="stats1_det" style="display:none">
                    <ul class="stats_det"><li class="stats_det">Usage memoire</li></ul><ul class="stats_det_nav"><li class="stats_det_nav" id="adv_1_det">Par jour</li><li class="stats_det_nav" id="adv_2_det">Par semaine</li><li class="stats_det_nav" id="adv_3_det">Par mois</li></ul><img src="../graph/img/@RTOM@_mem-day.png"><img src="../graph/img/@RTOM@_mem-week.png"><img src="../graph/img/@RTOM@_mem-month.png">
            </ul>
            <ul id="outputd_1" class="stats1_det" style="display:none">
                    <ul class="stats_det"><li class="stats_det">Nombre de torrents</li></ul><ul class="stats_det_nav"><li class="stats_det_nav" id="adv_1_det">Par jour</li><li class="stats_det_nav" id="adv_2_det">Par semaine</li><li class="stats_det_nav" id="adv_3_det">Par mois</li></ul><img src="../graph/img/@RTOM@_vol-day.png"><img src="../graph/img/@RTOM@_vol-week.png"><img src="../graph/img/@RTOM@_vol-month.png">
            </ul>
        </div>
        
        <script>
            onload=function(){
            document.getElementById("print_room_lk").href="";
            document.getElementById("print_cake_lk").href="";
            };
        </script>
    </body>
</html>
