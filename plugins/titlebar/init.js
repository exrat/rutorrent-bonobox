// Configuration
var personalTitle  = "Bonobox - ruTorrent v";
var versionRutorrent = "yes"; // yes or no
//

plugin.updateStatus = theWebUI.updateStatus;
theWebUI.updateStatus = function()
{
                var self = theWebUI;
                var ul = theConverter.speed(self.total.speedUL);
                var dl = theConverter.speed(self.total.speedDL);
                var newTitle = '';
                if(theWebUI.settings["webui.speedintitle"])
                {
                        if(ul.length)
                                newTitle+=('↑'+ul+' ');
                        if(dl.length)
                                newTitle+=('↓'+dl+' ');
                }

                if (versionRutorrent == "yes"){ newTitle+=(personalTitle)+self.version;
                } else { newTitle+=(personalTitle);
                }

                if(document.title!=newTitle)
                        document.title = newTitle;
                $("#stup_speed").text(ul);
                $("#stup_limit").text((self.total.rateUL>0 && self.total.rateUL<100*1024*1024) ? theConverter.speed(self.total.rateUL) : theUILang.no);
                $("#stup_total").text(theConverter.bytes(self.total.UL));
                $("#stdown_speed").text(dl);
                $("#stdown_limit").text((self.total.rateDL>0 && self.total.rateDL<100*1024*1024) ? theConverter.speed(self.total.rateDL) : theUILang.no);
                $("#stdown_total").text(theConverter.bytes(self.total.DL));
}

theWebUI.setStatusUpdate();

