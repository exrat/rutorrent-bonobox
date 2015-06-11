plugin.loadMainCSS();
plugin.loadLang();

plugin.addZero = function(num)
{
    if (num >= 10)
        return(num);
    else
        return('0' + String(num));
}

plugin.parseText = function(text)
{
    text = text.replace(/&(?!\w+([;\s]|$))/g, "&amp;");
    text = text.replace(/</g, "&lt;").replace(/>/g, "&gt;");

    if (plugin.settings["smileys"]) {
        text = text.replace(/&gt;:\)|&gt;:-\)/i, "<span id='devil" + plugin.settings["smileySet"] + "'></span>");
        text = text.replace(/:\(|:-\(/i, "<span id='frown" + plugin.settings["smileySet"] + "'></span>");
        text = text.replace(/:O|:-O/i, "<span id='shocked" + plugin.settings["smileySet"] + "'></span>");
        text = text.replace(/;\)|;-\)/i, "<span id='wink" + plugin.settings["smileySet"] + "'></span>");
        text = text.replace(/X\)|X-\)/i, "<span id='angry" + plugin.settings["smileySet"] + "'></span>");
        text = text.replace(/:\||:-\|/i, "<span id='straight" + plugin.settings["smileySet"] + "'></span>");
        text = text.replace(/(:\/|:-\/)[^\/]/i, "<span id='slant" + plugin.settings["smileySet"] + "'></span>");
        text = text.replace(/:D|:-D/i, "<span id='grin" + plugin.settings["smileySet"] + "'></span>");
        text = text.replace(/:P|:-P/i, "<span id='tongue" + plugin.settings["smileySet"] + "'></span>");
        text = text.replace(/:'\(|:'-\(/i, "<span id='sad" + plugin.settings["smileySet"] + "'></span>");
        text = text.replace(/&gt;\.&lt;/i, "<span id='wince" + plugin.settings["smileySet"] + "'></span>");
        text = text.replace(/:\)|:-\)/i, "<span id='smile" + plugin.settings["smileySet"] + "'></span>");
        text = text.replace(/8\)|8-\)|B\)|B-\)/i, "<span id='cool" + plugin.settings["smileySet"] + "'></span>");
        text = text.replace(/&lt;3/i, "<span id='love" + plugin.settings["smileySet"] + "'></span>");
    }

    var pattern = /(https?:\/\/|www\.)((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|((\d{1,3}\.){3}\d{1,3}))(\:\d+)?(\/[-a-z\d%_.~+]*)*(\?[;&a-z\d%_.~+=-]*)?(\#[-a-z\d_]*)?/gi;
    var matches = text.match(pattern);

    if (matches == null)
        return(text);

    for (var i = 0; i < matches.length; i++) {
        var replace = new RegExp(matches[i]);

        if (!matches[i].match(/http:\/\//))
            var url = "http://" + matches[i];
        else
            var url = matches[i];

        text = text.replace(replace, "<a href='" + url + "' target='_blank'>" + matches[i] + "</a>");
    }

    return(text);
}

theWebUI.showChat = function()
{
    plugin.active = true;
    theDialogManager.hide("stg");
    theDialogManager.toggle("tchat");
    $("#chatMessage").focus();
    $("#chatarea")[0].scrollTop = $("#chatarea")[0].scrollHeight;
}

plugin.getChat = function()
{
    if (plugin.msgTimeout) {
        window.clearTimeout(plugin.msgTimeout);
        plugin.msgTimeout = null;
    }

    theWebUI.request("?action=getchat", [plugin.updateChat,plugin], true);
}

plugin.updateChat = function(data)
{
    if (data.error)
        log("Chat plugin: " + data.error);
    else if (data.chat != plugin.currentChat)
        return(false);
    else {
        var s = "";
        for (var i = 0; i < data.lines.length; i++) {
            var dateTime = new Date(parseInt(data.lines[i].dt) + plugin.timeFix);
            var displayDT = "";
            for (var j = 0; j < plugin.settings["format"].length; j++) {
                switch (plugin.settings["format"].charAt(j)) {
                    case "D":
                        displayDT += plugin.addZero(dateTime.getDate());
                        break;
                    case "M":
                        displayDT += plugin.addZero(dateTime.getMonth() + 1);
                        break;
                    case "Y":
                        displayDT += plugin.addZero(dateTime.getFullYear());
                        break;
                    case "h":
                        displayDT += plugin.addZero(dateTime.getHours());
                        break;
                    case "m":
                        displayDT += plugin.addZero(dateTime.getMinutes());
                        break;
                    case "s":
                        displayDT += plugin.addZero(dateTime.getSeconds());
                        break;
                    case ".":
                    case "-":
                    case "/":
                    case ":":
                    case " ":
                        displayDT += plugin.settings["format"].charAt(j);
                        break;
                }
            }

            if (displayDT != "")
                s += "<i>" + displayDT + "</i> - ";
            s += "<strong>" + data.lines[i].user + "</strong>:<br />" + plugin.parseText(data.lines[i].msg) + "<br />";
        }

        if (s != "") {
            $("#chatarea").append(s);
            $("#chatarea")[0].scrollTop = $("#chatarea")[0].scrollHeight;
            if (plugin.settings["popup"] && !plugin.active && (plugin.lastLine[plugin.currentChat] > 0 || plugin.settings["lastLine"][plugin.currentChat] == undefined || (plugin.lastLine[plugin.currentChat] + i) > plugin.settings["lastLine"][plugin.currentChat])) {
                theDialogManager.show("tchat");
                $("#chatMessage").focus();
                $("#chatarea")[0].scrollTop = $("#chatarea")[0].scrollHeight;
                plugin.active = true;
            }
        }

        plugin.lastLine[plugin.currentChat] += i;

        if (plugin.active) {
            plugin.msgTimeout = window.setTimeout(plugin.getChat, plugin.settings["aInterval"]);
            if (plugin.lastLine[plugin.currentChat] != plugin.settings["lastLine"][plugin.currentChat]) {
                plugin.settings["lastLine"][plugin.currentChat] = plugin.lastLine[plugin.currentChat];
                theWebUI.request("?action=setchat", [plugin.checkSuccess,plugin], true);
            }
        } else
            plugin.msgTimeout = window.setTimeout(plugin.getChat, plugin.settings["iInterval"]);
    }
}

plugin.getList = function()
{
    theWebUI.request("?action=getchatlist", [plugin.updateList,plugin], true);
}

plugin.updateList = function(data)
{
    if (data.error)
        log("Chat plugin: " + data.error);
    else {
        var chats = 0;
        var options = "";
        var newLines = new Array();
        for (key in data.chatList) {
            if (data.chatList[key].newChat)
                newLines.push(key);

            var addClass = "";
            if (data.chatList[key].newChat && data.chatList[key].disabled)
                addClass = " class='newchat nopm'";
            else if (data.chatList[key].newChat)
                addClass = " class='newchat'";
            else if (data.chatList[key].disabled)
                addClass = " class='nopm'";

            chats++;
            options += "<option value='" + key + "'" + addClass + (key == plugin.currentChat ? " selected='selected'" : "") + ">" + (key == "main_chat" ? theUILang.chatEverybody : key) + "</option>";
        }

        $("#chatselect").html(options);
        $("#chatselect").removeAttr("style");
        if (chats > 20)
            $("#chatselect").attr("style", "width='80px;'");

        if (!plugin.active && newLines.length > 0) {
            plugin.currentChat = newLines[0];
            plugin.lastLine[newLines[0]] = 0;
            $("#chatarea").html("");
            $("#chatselect option:selected").removeAttr("selected");
            $("#chatselect option[value='" + newLines[0] + "']").removeClass("newchat").attr("selected", "selected");
        }

        plugin.listTimeout = window.setTimeout(plugin.getList, plugin.listInterval);
    }
}

theWebUI.sendChat = function()
{
    if ($("#chatMessage").val() == "")
        return(false);

    theWebUI.request("?action=sendchat", [plugin.checkSuccess,plugin], true);
    $("#chatMessage").val("");
}

theWebUI.clearChatConfirmed = function()
{
    if ($("#chatarea").html() == "")
        return(false);

    $("#chatarea").html("");
    theWebUI.request("?action=clearchat", [plugin.checkSuccess,plugin], true);
    plugin.lastLine[plugin.currentChat] = 0;
}

plugin.checkSuccess = function(data)
{
    if (data.error)
        log("Chat plugin: " + data.error);
    else if (data.errors)
        for (var i = 0; i < data.errors.length; i++)
            log("Chat plugin: " + data.errors[i].error + data.errors[i].file + (data.errors[i].user ? (theUILang.chatForUser + data.errors[i].user) : ""));
}

rTorrentStub.prototype.getchat = function()
{
    this.content = "action=getchat&chat=" + plugin.currentChat + "&line=" + plugin.lastLine[plugin.currentChat];
    this.contentType = "application/x-www-form-urlencoded";
    this.mountPoint = "plugins/chat/action.php";
    this.dataType = "json";
}

rTorrentStub.prototype.getchatlist = function()
{
    this.content = "action=getlist";
    this.contentType = "application/x-www-form-urlencoded";
    this.mountPoint = "plugins/chat/action.php";
    this.dataType = "json";
}

rTorrentStub.prototype.sendchat = function()
{
    this.content = "action=add&chat=" + plugin.currentChat + "&message=" + encodeURIComponent($("#chatMessage").val());
    this.contentType = "application/x-www-form-urlencoded";
    this.mountPoint = "plugins/chat/action.php";
    this.dataType = "json";
}

rTorrentStub.prototype.clearchat = function()
{
    this.content = "action=clear&chat=" + plugin.currentChat;
    this.contentType = "application/x-www-form-urlencoded";
    this.mountPoint = "plugins/chat/action.php";
    this.dataType = "json";
}

theWebUI.chatPrompt = function()
{
    var options = [
        { val: theUILang.chatTemporarily, func: "$(\"#chatarea\").html(\"\")" },
        { val: theUILang.chatPermanently, func: "theWebUI.clearChatConfirmed()" },
        { val: theUILang.Cancel }
    ];

    plugin.prompt(theUILang.chatClearPrompt, theUILang.chatClearPromptText, options);
}

plugin.onLangLoaded = function()
{
    this.addButtonToToolbar("chat", theUILang.mnu_chat, "theWebUI.showChat()", "settings");
    this.addSeparatorToToolbar("settings");

    var chats = 0;
    var options = "";
    var newLines = new Array();
    plugin.lastLine = new Array();
    for (key in plugin.chatList) {
        if (plugin.chatList[key].newChat)
            newLines.push(key);

        var addClass = "";
        if (plugin.chatList[key].newChat && plugin.chatList[key].disabled)
            addClass = " class='newchat nopm'";
        else if (plugin.chatList[key].newChat)
            addClass = " class='newchat'";
        else if (plugin.chatList[key].disabled)
            addClass = " class='nopm'";

        chats++;
        plugin.lastLine[key] = 0;
        options += "<option value='" + key + "'" + addClass + ">" + (key == "main_chat" ? theUILang.chatEverybody : key) + "</option>";
    }

    if (newLines.length > 0) {
        options = options.replace("value='" + newLines[0] + "'", "value='" + newLines[0] + "' selected='selected'");
        plugin.currentChat = newLines[0];
    } else {
        options = options.replace("value='main_chat'", "value='main_chat' selected='selected'");
        plugin.currentChat = 'main_chat';
    }

    var chatList = "";
    if (plugin.settings["pm"]) {
        chatList = ""+
        "<div id='chatusers'>"+
            "<fieldset>"+
                "<legend>" + theUILang.chatList + "</legend>"+
                "<div id='userlist'>"+
                    "<select id='chatselect' name='users' multiple='multiple'" + (chats > 20 ? " style='width='80px;'" : "") + ">"+
                        options+
                    "</select>"+
                "</div>"+
            "</fieldset>"+
        "</div>";
    }

    theDialogManager.make("tchat", theUILang.chat,
        chatList+
        "<div id='chatmessages'>"+
            "<fieldset>"+
                "<legend>" + theUILang.chatMessages + " &#8211; <a href='javascript://void();' onclick='theWebUI.chatPrompt()'>" + theUILang.chatClear + "</a></legend>"+
                "<div id='chatarea' class='smileysContainer'></div>"+
            "</fieldset>"+
            "<fieldset>"+
                "<legend>" + theUILang.chatAdd + (plugin.settings["smileys"] ? " &#8211; <a href='javascript://void();' onclick='theDialogManager.show(\"chatSmileys\")'>" + theUILang.chatSmileys.toLowerCase() + "</a>" : "") + "</legend>"+
                "<input type='text' name='chatMessage' id='chatMessage'/> <input type='button' value='" + theUILang.chatSend + "' class='Button' onclick='theWebUI.sendChat()'/>"+
            "</fieldset>"+
        "</div>"
    );

    if (plugin.settings["pm"]) {
        $("#chatselect").change(function()
        {
            var value = $(this).val();

            if (value.length != 1) {
                var options = [ { val: theUILang.ok } ];
                plugin.prompt(theUILang.chatError, theUILang.chatListPromptText, options);
                return(false);
            }

            var option = $("option:selected", this);
            option.removeClass("newchat");
            plugin.currentChat = value;
            $("#chatarea").html("");
            if (value == "main_chat") {
                $("#tchat-header").text(theUILang.chat);
                $("#chatMessage").removeAttr("disabled");
                $("#chatMessage").removeAttr("style");
                $("#chatMessage").focus();
            } else {
                if (option.attr("class") == "nopm") {
                    $("#tchat-header").text(theUILang.chatWith + " " + value + " (" + theUILang.chatDisabled + ")");
                    $("#chatMessage").attr("disabled", "disabled");
                    $("#chatMessage").attr("style", "background-color: #D0D0D0;");
                    $(this).blur();
                } else {
                    $("#tchat-header").text(theUILang.chatWith + " " + value);
                    $("#chatMessage").removeAttr("disabled");
                    $("#chatMessage").removeAttr("style");
                    $("#chatMessage").focus();
                }
            }

            plugin.lastLine[value] = 0;
            plugin.getChat();
        });
    }

    $("#chatMessage").keydown(function(event)
    {
        if ((event.which && event.which == 13) || (event.keyCode && event.keyCode == 13)) {
            theWebUI.sendChat();
        }
    });

    theDialogManager.setHandler("tchat", "afterHide", function()
    {
        plugin.active = false;
    });

    if (plugin.settings["smileys"]) {
        theDialogManager.make("chatSmileys", theUILang.chatSmileys,
            "<table class='smileysContainer'>"+
                "<tr>"+
                    "<td><span id='frown" + plugin.settings["smileySet"] + "' title=':('></span></td>"+
                    "<td><span id='shocked" + plugin.settings["smileySet"] + "' title=':o'></span></td>"+
                    "<td><span id='wink" + plugin.settings["smileySet"] + "' title=';)'></span></td>"+
                    "<td><span id='angry" + plugin.settings["smileySet"] + "' title='X)'></span></td>"+
                    "<td><span id='straight" + plugin.settings["smileySet"] + "' title=':|'></span></td>"+
                "</tr>"+
                "<tr>"+
                    "<td><span id='slant" + plugin.settings["smileySet"] + "' title=':/'></span></td>"+
                    "<td><span id='grin" + plugin.settings["smileySet"] + "' title=':D'></span></td>"+
                    "<td><span id='tongue" + plugin.settings["smileySet"] + "' title=':P'></span></td>"+
                    "<td><span id='sad" + plugin.settings["smileySet"] + "' title=\":'(\"></span></td>"+
                    "<td><span id='wince" + plugin.settings["smileySet"] + "' title='>.<'></span></td>"+
                "</tr>"+
                "<tr>"+
                    "<td><span id='smile" + plugin.settings["smileySet"] + "' title=':)'></span></td>"+
                    "<td><span id='cool" + plugin.settings["smileySet"] + "' title='8)'></span></td>"+
                    "<td><span id='devil" + plugin.settings["smileySet"] + "' title='>:)'></span></td>"+
                    "<td><span id='love" + plugin.settings["smileySet"] + "' title='<3'></span></td>"+
                    "<td></td>"+
                "</tr>"+
            "</table>"
        );

        $("table.smileysContainer tr td span").each(function()
        {
                $(this).click(function() {
                    $("#chatMessage").val($("#chatMessage").val() + " " + this.title);
                });
        });

        theDialogManager.setHandler("chatSmileys", "afterHide", function()
        {
            $("#chatMessage").focus();
        });
    }

    if (plugin.canChangeOptions()) {
        this.attachPageToOptions( $("<div>").attr("id", "st_chat").html(
            "<fieldset>"+
                "<legend>" + theUILang.chatSettings + "</legend>"+
                "<div class='op50l'>"+
                    "<input type='checkbox' id='chat.popup' " + (plugin.settings["popup"] ? "checked='checked' " : "") + "/> <label for='chat.popup'>" + theUILang.chatPopup + "</label>"+
                "</div>"+
                "<div class='op50l algnright'>"+
                    "<label for='chat.ainterval'>" + theUILang.chatActive + "</label><input type='text' id='chat.ainterval' class='Textbox' size='1' value='" + (plugin.settings["aInterval"] / 1000) + "' />s"+
                "</div>"+
                "<div class='op50l'>"+
                    "<input type='checkbox' id='chat.pm' " + (plugin.settings["pm"] ? "checked='checked' " : "") + "/> <label for='chat.pm'>" + theUILang.chatPMs + "*</label>"+
                "</div>"+
                "<div class='op50l algnright'>"+
                    "<label for='chat.iinterval'>" + theUILang.chatInactive + "</label><input type='text' id='chat.iinterval' class='Textbox' size='1' value='" + (plugin.settings["iInterval"] / 1000) + "' />s"+
                "</div>"+
                "<div class='op100l'>"+
                    "<label for='chat.format'>" + theUILang.chatFormat + "</label><input type='text' id='chat.format' class='Textbox' size='10' value='" + plugin.settings["format"] + "' />"+
                "</div>"+
                "<div class='op100l'>"+
                    theUILang.chatFormatHelp+
                "</div>"+
            "</fieldset>"+
            "<fieldset>"+
                "<legend>" + theUILang.chatSmileys + "</legend>"+
                "<div class='op50l'>"+
                    "<input type='checkbox' id='chat.smileys' " + (plugin.settings["smileys"] ? "checked='checked' " : "") + "/><label for='chat.smileys'>" + theUILang.chatShowSmileys + "*</label>"+
                "</div>"+
                "<div class='op50l algnright'>"+
                    "<label for='chat.smileyset'>" + theUILang.chatSmileySet + "</label><select id='chat.smileyset'>"+
                        "<option value='1'" + (plugin.settings["smileySet"] == 1 ? " selected='selected'" : "") + ">" + theUILang.chatSmileyRound + "</option>"+
                        "<option value='2'" + (plugin.settings["smileySet"] == 2 ? " selected='selected'" : "") + ">" + theUILang.chatSmileySquare + "</option>"+
                    "</select>"+
                "</div>"+
            "</fieldset>"+
            "<div>"+
                "&ensp;* " + theUILang.chatRefresh+
            "</div>"
        )[0], theUILang.chat);

        theDialogManager.setHandler("stg", "beforeShow", function()
        {
            theDialogManager.hide("tchat");

            if (plugin.msgTimeout) {
                window.clearTimeout(plugin.msgTimeout);
                plugin.msgTimeout = null;
            }
        });

        theDialogManager.setHandler("stg", "afterHide", function()
        {
            plugin.getChat();
        });
    }

    theDialogManager.make("chatPrompt", "",
        "<div id='chatPrompt-content' class='content'></div>"+
        "<div id='chatPrompt-buttons' class='aright buttons-list'></div>",
        true);

    if (plugin.settings["pm"])
        plugin.listTimeout = window.setTimeout(plugin.getList, plugin.listInterval);

    plugin.refreshOnUpdate = false;
    plugin.getChat();
}

plugin.onRemove = function()
{
    theDialogManager.hide("tchat");

    this.removeSeparatorFromToolbar("settings");
    this.removeButtonFromToolbar("chat");

    if (plugin.canChangeOptions())
        this.removePageFromOptions("st_chat");

    if (plugin.msgTimeout) {
        window.clearTimeout(plugin.msgTimeout);
        plugin.msgTimeout = null;
    }

    if (plugin.listTimeout) {
        window.clearTimeout(plugin.listTimeout);
        plugin.listTimeout = null;
    }

    plugin.active = false;
}

rTorrentStub.prototype.setchat = function()
{
    this.content = "action=settings";
    this.content += "&popup=" + ($($$("chat.popup")).attr("checked") ? 1 : 0);
    this.content += "&pm=" + ($($$("chat.pm")).attr("checked") ? 1 : 0);
    this.content += "&aInterval=" + $($$("chat.ainterval")).val();
    this.content += "&iInterval=" + $($$("chat.iinterval")).val();
    this.content += "&smileys=" + ($($$("chat.smileys")).attr("checked") ? 1 : 0);
    this.content += "&smileySet=" + $($$("chat.smileyset")).val();
    this.content += "&format=" + $($$("chat.format")).val();
    for (var chat in plugin.settings["lastLine"])
        this.content += "&lastLine[" + chat + "]=" + plugin.settings["lastLine"][chat];
    this.contentType = "application/x-www-form-urlencoded";
    this.mountPoint = "plugins/chat/action.php";
    this.dataType = "json";
}

plugin.updateSettings = function(data)
{
    if (data.error) {
        log("Chat plugin: " + data.error);
        if (data.popup) {
            theDialogManager.show("stg");
            var options = [ { val: theUILang.ok } ];
            plugin.prompt(theUILang.chatError, data.error, options);
        }
    } else {
        plugin.settings = data;
        if (plugin.refreshOnUpdate)
            theWebUI.reload();
    }
}

plugin.prompt = function(title, message, options)
{
        var buttons = "";
        for (var i = 0; i < options.length; i++)
            buttons += "<input type='button' class='Button' value='" + options[i].val + "' onclick='" + (options[i].func != undefined ? options[i].func + ";" : "") + "theDialogManager.hide(\"chatPrompt\"); return(false);' />";

        $("#chatPrompt-header").html(title);
        $("#chatPrompt-content").html(message);
        $("#chatPrompt-buttons").html(buttons);
        theDialogManager.show("chatPrompt");
}

plugin.setSettings = theWebUI.setSettings;
theWebUI.setSettings = function()
{
    plugin.setSettings.call(this);
    var update = false;

    if ($($$("chat.popup")).attr("checked") && !plugin.settings["popup"] || !$($$("chat.popup")).attr("checked") && plugin.settings["popup"])
        update = true;

    if ($($$("chat.pm")).attr("checked") && !plugin.settings["pm"] || !$($$("chat.pm")).attr("checked") && plugin.settings["pm"]) {
        plugin.refreshOnUpdate = true;
        update = true;
    }

    if ($($("chat.ainterval")).val() != plugin.settings["aInterval"])
        update = true;

    if ($($("chat.iinterval")).val() != plugin.settings["iInterval"])
        update = true;

    if ($($$("chat.format")).val() != plugin.settings["format"])
        update = true;

    if ($($$("chat.smileys")).attr("checked") && !plugin.settings["smileys"] || !$($$("chat.smileys")).attr("checked") && plugin.settings["smileys"]) {
        plugin.refreshOnUpdate = true;
        update = true;
    }

    if ($($$("chat.smileyset")).val() != plugin.settings["smileySet"])
        update = true;

    if (update)
        theWebUI.request("?action=setchat", [plugin.updateSettings,plugin], true);
}
