<?php

$user = getUser();
$host = $_SERVER['HTTP_HOST'];

require_once('conf.php');

$optionlink = $onglet === true ? 'window.open':'window.location.replace';

$jResult .= "plugin.url = '".$url."';";
$jResult .= "plugin.optionlink = '".$optionlink."';";

$theSettings->registerPlugin("linkproxy");

