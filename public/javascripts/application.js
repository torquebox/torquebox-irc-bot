// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function fetchMessages() {
  $.ajax({
    url: '/',
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
