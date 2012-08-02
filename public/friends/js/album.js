var _page = 0;
var jump_pict = function(data){
  $("#main").html("");
  $.each(data.picture, function(){
    $("#main").append("<div class=\"span-6\"><a href=\"./pic/" + this + "\" target=\"_blank\"><img src=\"./tumb/" + this +"\" /></a></span>");
  });
}
$(document).ready(function(){

  $('#picture').click(function(){
    _page = 0;
    $.getJSON("./pictures", {"page": _page}, jump_pict);
    $("#pager").html("");
    $("#pager").append("<a id=\"prev\" href=\"#\" class=\"button\">&lt;</a>");
    $("#pager").append("<a id=\"next\" href=\"#\" class=\"button\">&gt;</a>");
    $("#prev").click(function(){
      if(_page > 0) { _page--; }
      $.getJSON("./pictures", {"page": _page}, jump_pict);
    });
    $("#next").click(function(){
      _page++;
      $.getJSON("./pictures", {"page": _page}, jump_pict);
    });
  });

  $('#video').click(function(){
    $("#pager").html("");
    $.getJSON("./videos", function(data){
      $("#main").html("");
      $.each(data.video,  function(){
        $("#main").append("<a class=\"button video\">" + this + "</a");
      });
      $("#main").append("<div id=\"player\" class=\"span-24\"></div>");
      $(".video").click(function(){
        $("#player").html("<video src=\"./video/" + $(this).text() + "\" controls></vide>");
      });
    });
  });

  $('#upload').change(function(){
    $(this).upload('./upload', function(res) {
        $("#main").append("<div class=\"span-6\"><a href=\"./pic/" + res + "\" target=\"_blank\"><img src=\"./tumb/" + res +"\" /></a></span>");
    },'text');
  });
});
