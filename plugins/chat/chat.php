<?php
require_once(dirname(__FILE__) . "/../../php/cache.php");
eval(getPluginConf("chat"));

class rChat {
    public $hash = "chat.dat";
    public $popup = "";
    public $pm = "";
    public $aInterval = "";
    public $iInterval = "";
    public $smileys = "";
    public $smileySet = "";
    public $format = "";
    public $lastLine = array();

    static public function load() {
        global $defaultPopup, $defaultPMsEnabled, $defaultActiveInterval, $defaultInactiveInterval, $defaultUseSmileys, $defaultSmileySet, $defaultDtFormat;

        $cache = new rCache();
        $chat = new rChat();
        if(!$cache->get($chat)) {
            $chat->popup = $defaultPopup;
            $chat->pm = $defaultPMsEnabled;
            $chat->aInterval = $defaultActiveInterval;
            $chat->iInterval = $defaultInactiveInterval;
            $chat->smileys = $defaultUseSmileys;
            $chat->smileySet = $defaultSmileySet;
            $chat->format = $defaultDtFormat;
            $chat->lastLine = array();
        }
        return $chat;
    }

    public function store() {
        $cache = new rCache();
        return $cache->set($this);
    }

    public function get() {
        $settings = array(
            "popup" => $this->popup,
            "pm" => $this->pm,
            "aInterval" => ($this->aInterval * 1000),
            "iInterval" => ($this->iInterval * 1000),
            "smileys" => $this->smileys,
            "smileySet" => $this->smileySet,
            "format" => $this->format,
            "lastLine" => $this->lastLine
        );
        return $settings;
    }

    public function set($settings) {
        if (is_array($settings)) {
            $this->popup = $settings["popup"];
            $this->pm = $settings["pm"];
            $this->aInterval = $settings["aInterval"];
            $this->iInterval = $settings["iInterval"];
            $this->smileys = $settings["smileys"];
            $this->smileySet = $settings["smileySet"];
            $this->format = $settings["format"];
            $this->lastLine = $settings["lastLine"];

            return $this->store();
        }
        return FALSE;
    }
}
?>
