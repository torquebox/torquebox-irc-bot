
$( function() {
  client = Stomp.client( "ws://localhost:8675/" )

  client.debug = function(message) {
    console.debug( message )
  }

  client.connect( null, null, function() {
    $(window).unload(function() { client.disconnect() });
    
    client.subscribe( '/stomplet/irc', function(message) {
      // received a message!
      var html = "<li><span class='ts'>["+message.headers.timestamp+"]</span> <span class='nick'>"+message.headers.sender+":</span> "+message.body+"</li>"
      $("#messages").append(html)
    } )
  } )

} )

