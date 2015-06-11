//
// ruTorrent Torrent-Addition Auto-Labels
// Version 0.8 
// by thezwallrus
//

//
// jquery replace
//

$("#tadd_label").wrap('<div id="taddl_cont" />').remove();
$("#taddl_cont").append('<select id="tadd_label" name="tadd_label" style="width:120px;margin-left:4px;"></select>'+
			'<input type="text" id="newLabel" value="'+ theUILang.New_label +'" title="'+ theUILang.New_label +'" style="width:90px;"/>'+
			'<input type="button" id="add_newLabel" value="+" class="Button" style="width:25px;" />');
$("#tadd_label").append($('<OPTION></OPTION>')
		.val('')
		.text(''));

$('#addtorrent label').css({'margin-top':'4px'});
$('#addtorrent label:eq(4)').css({'margin-top':'10px'});
$('#addtorrenturl label').css({'margin-top':'4px'});

//
// jQuery listeners
//

var addLab = $('#add_newLabel');
addLab.click( function() {
	setTimeout( function() {
		$('#tadd_label')
		.append($('<OPTION></OPTION>')
		.val( $('#newLabel').val() )
		.text( $('#newLabel').val() )
		.attr('selected','selected') );
		$('#newLabel').val( $('#newLabel').attr('title') );
	}, 300)
});



var newLab = $('#newLabel');

newLab.focus( function() {
	if(this.value == $(this).attr('title')) {
		this.value='';
	}
});

newLab.blur( function() {
	if(this.value == '') {
		this.value = $(this).attr('title');
	}
});

//
// load labels into dropdown
//

theWebUI.initLabelDirs = function()
{
		setTimeout( function() {
			jQuery.each(theWebUI.cLabels, function(lbl, nothing) {
				$('#tadd_label').append($('<OPTION></OPTION>').val(lbl).html(lbl));
			})
		}, 3000 );
	        plugin.markLoaded();
};

theWebUI.initLabelDirs();

//
// ruTorrent Nested Categorical Label-Sorter "/"
// Version 0.8
// by thezwallrus
//

plugin.loadLabels = theWebUI.loadLabels;
theWebUI.loadLabels = function(d)
{
	if (plugin.enabled)
	{
		var p = $("#lbll");
		var subArray = [];
		var temp = new Array();
		for(var lbl in d) 
		{
			this.labels["-_-_-" + lbl + "-_-_-"] = d[lbl];
			this.cLabels[lbl] = 1;
			temp["-_-_-" + lbl + "-_-_-"] = true;
			if(!$$("-_-_-" + lbl + "-_-_-")) 
			{
				var splitlbl = lbl.split("/");
				if (splitlbl.length>1)
				{
					var family = splitlbl.shift();
					var catlbl = splitlbl.join("/");
					var moveOver = "&nbsp;&nbsp;-";
					if ( $.inArray(family, subArray) < 0  )
					{
						subArray.push(family);
					}
				} else {
					catlbl = lbl;
					moveOver = "";
				}
				p.append( $("<LI>").
					attr("id","-_-_-" + lbl + "-_-_-").
					html(moveOver + escapeHTML(catlbl) + "&nbsp;(<span id=\"-_-_-" + lbl + "-_-_-c\">" + d[lbl] + "</span>)").
					mouseclick(theWebUI.labelContextMenu).addClass("cat") );
			}
		}
		for (var dadlbl in subArray) 
		{
			if(!$$("-_-_-" + subArray[dadlbl] + "-_-_-")) 
			{
				$('#lbll').append( $('<LI>').html(subArray[dadlbl]).css("cursor","default") );
			} else {
				$("#-_-_-" + subArray[dadlbl] + "-_-_-").remove().appendTo( $('#lbll') ).mouseclick(theWebUI.labelContextMenu).addClass("cat");
			}
			$("li[id^='-_-_-" + subArray[dadlbl] + "']").not( $("#-_-_-" + subArray[dadlbl] + "-_-_-") ).remove().appendTo( $('#lbll') ).mouseclick(theWebUI.labelContextMenu).addClass("cat");
		}
		var actDeleted = false;
		p.children().each(function(ndx,val)
		{
		        var id = val.id;
			if(id && !$type(temp[id]))
			{
				$(val).remove();
				delete theWebUI.labels[id];
				delete theWebUI.cLabels[id.substr(5, id.length - 10)];
				if(theWebUI.actLbl == id) 
					actDeleted = true;
			}
		});
		if(actDeleted) 
		{
			this.actLbl = "";
			this.switchLabel($$("-_-_-all-_-_-"));
		}
   	} else
	{
		plugin.loadLabels.call(theWebUI,d);
	}
}
