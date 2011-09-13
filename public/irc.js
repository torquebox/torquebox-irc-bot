function fetchMessages() {
  $.ajax({
    url: '/?format=json',
    dataType: 'json',
    success: function(data) {
      $(data).each(function(index, message) {
        var html = "<li>" + message + "</li>";
        $("#messages").append(html);
      });
      setTimeout(function() { fetchMessages(); }, 1500);
    }
  });
}

$(function() {
  fetchMessages();
});
