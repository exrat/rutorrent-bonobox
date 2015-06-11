<?php
require_once("chat.php");
eval(getPluginConf("chat"));

$chatDir = getSettingsPath() . "/chat";
if (!file_exists($chatDir) || !is_dir($chatDir))
    mkdir($chatDir);

$chat = rChat::load();
$chatSettings = $chat->get();

$chatList = array();
$chatList["main_chat"] = array();
$chatList["main_chat"]["newChat"] = file_exists($chatDir . "/main_chat.log.new");
$chatList["main_chat"]["disabled"] = false;

if ($chatSettings["pm"]) {
    $me = getUser();
    $users = scandir($rootPath . "/share/users/");
    if ($users && count($users) > 0) {
        foreach ($users as $user) {
            if ($user[0] == "."|| $user == $me)
                continue;

            $chatList[$user] = array();
            $chatList[$user]["newChat"] = file_exists($chatDir . "/" . $user . ".log.new");
            $chatList[$user]["disabled"] = file_exists($rootPath . "/share/users/" . $user . "/settings/chat/nopm");
        }
    }
}

$jResult .= "plugin.chatList = " . json_encode($chatList) . ";";
$jResult .= "plugin.settings = " . json_encode($chatSettings) . ";";
$jResult .= "plugin.listInterval = " . ($defaultListInterval * 1000) . ";";
$jResult .= "plugin.timeFix = (new Date().getTime()) - " . round(microtime(true) * 1000) . ";";

$theSettings->registerPlugin("chat");
?>
