<?php
require_once(dirname(__FILE__) . "/../../php/util.php");
require_once("chat.php");
eval(getPluginConf("chat"));
unset($ret);

function updateChatLog($chat) {
    $log = getSettingsPath() . "/chat/" . $chat . ".log";

    if (!file_exists($log . ".new"))
        return FALSE;

    if (!is_readable($log . ".new"))
        return "theUILang.newUnreadable";

    if (filesize($log . ".new") == 0) {
        if (!unlink($log . ".new"))
            return "theUILang.newUndeletable";
        else
            return FALSE;
    }

    if (!file_exists($log) || filesize($log) == 0) {
        if (!copy($log . ".new", $log))
            return "theUILang.logUnwritable";
        else {
            if (!unlink($log . ".new"))
                return "theUILang.newDeleteFail";
            else
                return FALSE;
        }
    }

    if (!is_writable($log))
        return "theUILang.logUnwritable";

    if (!file_put_contents($log, implode("", file($log . ".new")), FILE_APPEND))
        return "theUILang.logWriteError";

    if (!unlink($log . ".new"))
        return "theUILang.newDeleteFail";
    else
        return FALSE;
}

function writeToChatLog($message, $to, $from = NULL) {
    global $rootPath;

    $chatDir = $rootPath . "/share/users/" . $to . "/settings/chat";
    if ((!file_exists($chatDir) || !is_dir($chatDir)) && !mkdir($chatDir))
        return "{ \"error\": theUILang.dirCreateError, \"user\": \"" . $to . "\" }";

    if ($from == NULL)
        $log = "/main_chat.log.new";
    else
        $log = "/" . $from . ".log.new";

    if (file_exists($chatDir . $log) && !is_writable($chatDir . $log))
        return "{ \"error\": theUILang.newUnwritable, \"file\": \"" . $log . "\", \"user\": \"" . $to . "\" }";

    $handle = fopen($chatDir . $log, "a");
    if (!$handle)
        return "{ \"error\": theUILang.handleOpenError, \"file\": \"" . $log . "\", \"user\": \"" . $to . "\" }";

    $errors = array();
    if (!flock($handle, LOCK_EX)) {
        $errors[] = "{ \"error\": theUILang.acquireLockError, \"file\": \"" . $log . "\", \"user\": \"" . $to . "\" }";

        if (!fclose($handle))
            $errors[] = "{ \"error\": theUILang.handleCloseError, \"file\": \"" . $log . "\", \"user\": \"" . $to . "\" }";
    } else {
        if (!fwrite($handle, $message))
            $errors[] = "{ \"error\": theUILang.newWriteError, \"file\": \"" . $log . "\", \"user\": \"" . $to . "\" }";

        if (!flock($handle, LOCK_UN))
            $errors[] = "{ \"error\": theUILang.releaseLockError, \"file\": \"" . $log . "\", \"user\": \"" . $to . "\" }";

        if (!fclose($handle))
            $errors[] = "{ \"error\": theUILang.handleCloseError, \"file\": \"" . $log . "\", \"user\": \"" . $to . "\" }";
    }

    return implode(",", $errors);
}

function getChatList() {
    global $rootPath;

    $chatDir = getSettingsPath() . "/chat";
    $chatList = array();
    $chatList["main_chat"] = array();
    $chatList["main_chat"]["newChat"] = file_exists($chatDir . "/main_chat.log.new");
    $chatList["main_chat"]["disabled"] = false;

    $me = getUser();
    $users = scandir($rootPath . "/share/users/");
    if ($users && count($users) > 0) {
        foreach ($users as $user) {
            if ($user[0] == "." || $user == $me)
                continue;

            $chatList[$user] = array();
            $chatList[$user]["newChat"] = file_exists($chatDir . "/" . $user . ".log.new");
            $chatList[$user]["disabled"] = file_exists($rootPath . "/share/users/" . $user . "/settings/chat/nopm");
        }
    }

    return $chatList;
}

function validChat($chat) {
    if (preg_match("/[^a-z0-9_-]/i", $chat) !== 0)
        return FALSE;
    else
        return TRUE;
}

if (!empty($_REQUEST["action"])) {
    switch ($_REQUEST["action"]) {
        case "add":
            if (empty($_REQUEST["chat"]) || !validChat($_REQUEST["chat"]) || empty($_REQUEST["message"]))
                break;

            $me = getUser();
            $message = round(microtime(true) * 1000) . "~" . $me . "~" . $_REQUEST["message"] . "\n";
            $errors = array();
            if ($_REQUEST["chat"] != "main_chat") {
                $errors[] = writeToChatLog($message, $me, $_REQUEST["chat"]);
                $errors[] = writeToChatLog($message, $_REQUEST["chat"], $me);
            } else {
                $errors[] = writeToChatLog($message, $me);

                $chats = getChatList();
                foreach ($chats as $chat => $values) {
                    if ($chat == "main_chat")
                        continue;
                    $errors[] = writeToChatLog($message, $chat);
                }
            }

            $errors = implode(",", $errors);
            if (trim($errors, ",") == "")
                $ret = "{ \"success\": true }";
            else
                $ret = "{ \"errors\": [ " . $errors . "] }";
            break;
        case "getlist":
            $ret = "{ \"chatList\": " . json_encode(getChatList()) . " }";
            break;
        case "getchat":
            $req = 0 + $_REQUEST["line"];
            if (empty($_REQUEST["chat"]) || !validChat($_REQUEST["chat"]) || !isset($_REQUEST["line"]) || !is_numeric($req) || $req < 0 || floor($req) != $req)
                break;

            $error = updateChatLog($_REQUEST["chat"]);
            if ($error !== FALSE) {
                $ret = "{ \"error\": " . $error . " }";
                break;
            }

            if (!file_exists(getSettingsPath() . "/chat/" . $_REQUEST["chat"] . ".log")) {
                $ret = "{ \"chat\": \"" . $_REQUEST["chat"] . "\", \"lines\": [] }";
                break;
            }

            $lines = file(getSettingsPath() . "/chat/" . $_REQUEST["chat"] . ".log");
            if (!$lines) {
                $ret = "{ \"error\": theUILang.logUnreadable }";
                break;
            }
            if (count($lines) > $req) {
                $newLines = array_slice($lines, $req);
                $lines = array();
                foreach ($newLines as $line) {
                    $timePos = strpos($line, "~");
                    $userPos = strpos($line, "~", $timePos + 1);
                    $ln["dt"] = substr($line, 0, $timePos);
                    $ln["user"] = substr($line, $timePos + 1, $userPos - $timePos - 1);
                    $ln["msg"] = trim(substr($line, $userPos + 1));
                    $lines[] = $ln;
                }

                $ret = "{ \"chat\": \"" . $_REQUEST["chat"] . "\", \"lines\": " . json_encode($lines) . " }";
            } else
                $ret = "{ \"chat\": \"" . $_REQUEST["chat"] . "\", \"lines\": [] }";
            break;
        case "clear":
            if (empty($_REQUEST["chat"]) || !validChat($_REQUEST["chat"]))
                break;

            if (!unlink(getSettingsPath() . "/chat/" . $_REQUEST["chat"] . ".log"))
                $ret = "{ \"\": theUILang.logDeleteFail }";
            else
                $ret = "{ \"success\": \"true\" }";
            break;
        case "settings":
            $aInterval = 0 + $_REQUEST["aInterval"];
            if (!is_numeric($aInterval) || $aInterval < 1 || floor($aInterval) != $aInterval) {
                $ret = "{ \"error\": theUILang.chatAIntervalError, \"popup\": true }";
                break;
            }

            $iInterval = 0 + $_REQUEST["iInterval"];
            if (!is_numeric($iInterval) || $iInterval < 1 || floor($iInterval) != $iInterval) {
                $ret = "{ \"error\": theUILang.chatIIntervalError, \"popup\": true }";
                break;
            }

            $smileySet = 0 + $_REQUEST["smileySet"];
            if (!is_numeric($smileySet) || $smileySet < 1 || floor($smileySet) != $smileySet) {
                $ret = "{ \"error\": theUILang.chatSmileySetError, \"popup\": true }";
                break;
            }

            if (preg_match("/[^DMYhms:.\/ -]/", $_REQUEST["format"]) !== 0) {
                $ret = "{ \"error\": theUILang.chatFormatError, \"popup\": true }";
                break;
            }

            $lastLine = array();
            if (is_array($_REQUEST["lastLine"]))
                foreach ($_REQUEST["lastLine"] as $chat => $line)
                    if (validChat($chat) && is_numeric($line) && floor($line) == $line)
                        $lastLine[$chat] = 0 + $line;

            $settings = array();
            $settings["popup"] = ($_REQUEST["popup"] ? 1 : 0);
            $settings["pm"] = ($_REQUEST["pm"] ? 1 : 0);
            $settings["aInterval"] = $aInterval;
            $settings["iInterval"] = $iInterval;
            $settings["smileys"] = ($_REQUEST["smileys"] ? 1 : 0);
            $settings["smileySet"] = $smileySet;
            $settings["format"] = $_REQUEST["format"];
            $settings["lastLine"] = $lastLine;

            if ($settings["pm"] && file_exists(getSettingsPath() . "/chat/nopm")) {
                if (!unlink(getSettingsPath() . "/chat/nopm"))
                    $ret = "{ \"error\": theUILang.chatPMError }";
            } elseif (!$settings["pm"])
                if (!touch(getSettingsPath() . "/chat/nopm"))
                    $ret = "{ \"error\": theUILang.chatPMError }";

            $chat = new rChat();
            if (!$chat->set($settings))
                $ret = "{ \"error\": theUILang.chatSettingsSave }";
            else
                $ret = json_encode($chat->get());
            break;
    }
}

if (empty($ret))
   $ret = "{ \"error\": theUILang.chatInvalidReq }";

cachedEcho($ret, "application/json");
?>
