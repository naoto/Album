#!/usr/bin/env ruby

require 'sinatra'
require 'sinatra/contrib'
require 'erb'
require 'json'
require 'RMagick'

ORIGIN = "public/friends/original"
ITEM = 9

namespace '/friends' do

  get '/' do
    erb :index
  end

  get '/videos' do
    {video: Dir.glob("public/friends/video/**/*").map { |f| f.gsub(/^public\/friends\/video\//,'') }.sort }.to_json
  end

  get '/pictures' do
    begin
      params[:page] ||= 1
      start = params[:page].to_i * ITEM
      limit = start + ITEM
      {picture: Dir.glob("#{ORIGIN}/picture/**/*")[start...limit].map { |f| f.gsub(/^#{ORIGIN}\/picture\//,'')}.sort }.to_json
    rescue => e
      {picture: []}.to_json
    end
  end

  get '/tumb/:filename' do
    path = "public/tumb/#{params[:filename]}"
    Magick::ImageList.new("#{ORIGIN}/picture/#{params[:filename]}").resize_to_fill(240,240).write(path) unless File.exists?(path)
    open(path).read
  end

  get '/pic/:filename' do
    @filename = params[:filename]
    erb :pic
  end

  get '/pic/L/:filename' do
    path = "public/L/#{params[:filename]}"
    Magick::ImageList.new("#{ORIGIN}/picture/#{params[:filename]}").resize_to_fit(1024,960).write(path) unless File.exists?(path)
    open(path).read
  end

  post '/upload' do
    File.open("#{ORIGIN}/picture/#{params[:file][:filename]}", 'wb'){ |f| f.write(params[:file][:tempfile].read) } if params[:file]
    params[:file][:filename]
  end


end

__END__

@@ pic
<html>
  <head>
    <title><e</title>
    <link rel="stylesheet" href="../css/screen.css" type="text/css" media="screen, projection">
    <link rel="stylesheet" href="../css/print.css" type="text/css" media="print">
    <!--[if IE]>
      <link rel="stylesheet" href="../css/ie.css" type="text/css" media="screen, projection">
    <![endif]-->
    <link rel="stylesheet" href="../css/style.css" type="text/css" media="screen, projection">
  </head>
  <body>
  <div class="container">
      <h1 id="title" class="span-16">Album</h1>
      <div class="span-8">
        <a id="original" href="../original/picture/<%= @filename %>" class="button">ORIGINAL</a>
      </div>
  </div>
  <div class="container">
    <div id="main" class="span-24">
      <img src="./L/<%= @filename %>"/>
    </div>
  </div>
  </body>
</html>

@@ index
<html>
  <head>
    <title><e</title>
    <link rel="stylesheet" href="css/screen.css" type="text/css" media="screen, projection">
    <link rel="stylesheet" href="css/print.css" type="text/css" media="print">
    <!--[if IE]>
      <link rel="stylesheet" href="css/ie.css" type="text/css" media="screen, projection">
    <![endif]-->
    <link rel="stylesheet" href="css/style.css" type="text/css" media="screen, projection">
    <script src="js/jquery-1.7.2.min.js"></script>
    <script src="js/jquery.upload-1.0.2.min.js"></script>
    <script>
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
    </script>
  </head>
  <body>
  <div class="container">
      <h1 id="title" class="span-16">Album</h1>
      <div class="span-10">
        <a id="video" href="#" class="button">VIDEO</a>
        <a id="picture" href="#" class="button">PICTURE</a>
        <input type="file" clsas="upload" name="file" id="upload"/>
      </div>
  </div>
  <div class="container">
    <div id="main" class="span-24">
    </div>
    <div id="pager" class="span-24">
    </div>
  </div>
  </body>
</html>
