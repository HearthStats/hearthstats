//= require 'plugins/flot/jquery.flot.min.js'
//= require 'plugins/flot/jquery.flot.time.min.js'
//= require 'plugins/jquery.dataTables.min.js'
//= require 'page_specific/decklist.js'

$(document).ready(function() {
  $('.reveal').click(function (){
    $(this).fadeOut(function(){
      $('.user-key').fadeIn();
    });
  });
});
