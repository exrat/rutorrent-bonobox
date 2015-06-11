plugin.loadLang();

if(plugin.enabled && plugin.canChangeMenu()) {
	theWebUI.showNFO = function(id) {
		$("#nfo_text").html("Loading...");
		theDialogManager.show("dlg_nfo");

		var AjaxReq = jQuery.ajax({
			type: "GET",
			timeout: theWebUI.settings["webui.reqtimeout"],
			async : true,
			cache: false,
			data: "id=" + id,
			url : "plugins/nfo/view.php",
			success: function(data){
				if (data == '') {
					theDialogManager.hide("dlg_nfo");
					askYesNo( theUILang.nfoNotFoundTitle, theUILang.nfoNotFound, "" );
					return;
				}
				$("#nfo_text").html(data);
				theDialogManager.center("dlg_info");
			}
		});

	}

	plugin.createMenu = theWebUI.createMenu;
	theWebUI.createMenu = function( e, id ) {
		plugin.createMenu.call(this, e, id);
		if(plugin.enabled) {
			theContextMenu.add( [theUILang.showNFO, "theWebUI.showNFO('" + id + "')"] );

	                theDialogManager.make( 'dlg_nfo', "NFO", ''+
	                        '<pre style=" font-size: 8px; line-height: 8px; width: 600px; height: 450px; '+
	                        'overflow: auto; margin: 0px; font-family: Terminal, monospace;" '+
	                        'id="nfo_text">Loading...</pre>');
		}
	}
}
