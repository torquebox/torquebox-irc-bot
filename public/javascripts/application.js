
$( function() {
  client = Stomp.client( "ws://localhost:8675/" )

  client.debug = function(message) {
    console.debug( message )
  }

  client.connect( null, null, function() {
    $(window).unload(function() { client.disconnect() });
    
    client.subscribe( '/stomplet/irc', function(message) {
      // received a message!
      var html = "<li>" + message.body + "</li>"
      $("#messages").append(html)
    } )
  } )

} )

