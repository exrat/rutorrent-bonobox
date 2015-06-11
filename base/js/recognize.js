(function($){
  var words = null;
  var keys = [];
  var torrent = "84,79,82,82,69,78,84";
  var manager = "77,65,78,65,71,69,82";

  $(document).keydown( function (e) {
    keys.push( e.keyCode );
    if ( keys.toString().indexOf( torrent ) >= 0 ) {
      launchCommand("/rutorrent");
    } else if (keys.toString().indexOf( manager ) >= 0) {
      launchCommand("/seedbox-manager");
    }
  });

  if ('webkitSpeechRecognition' in window) {
    var recognition = new webkitSpeechRecognition();

    recognition.lang = "fr-FR";
    recognition.continuous = true;
    recognition.interimResults = true;

    $(document).ready( function () {
      setTimeout( function() {
        recognition.start();
      }, 100);
    });
    recognition.onend = function() {
      recognition.start();
    }
    recognition.onresult = function(event) {
      for (var i = event.resultIndex; i < event.results.length; i++) {
        var transcript = event.results[i][0].transcript;
        if ( event.results[i].isFinal){
          words = transcript.split(" ");
          recognition.stop();
          for ( var word = 0 ; word < words.length; word++) {
            switch (words[word]) {
              case "torrent":
                launchCommand("/rutorrent");
                break;
              case "manager":
                launchCommand("/seedbox-manager");
                break;
              default:
                break;
            }
          }
        }
      }
    }
  }
})(jQuery);

function launchCommand(path) {
  window.location.replace(path);
};
