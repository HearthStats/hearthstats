//= require 'plugins/flot/jquery.flot.min.js'
//= require 'plugins/flot/jquery.flot.pie.min.js'
//= require 'plugins/jquery.selectBoxIt.js'
//= require 'site_wide/app.js'
//= require 'plugins/jquery.tagsinput.min.js'
//= require 'plugins/list.min.js'
//= require 'plugins/list.pagination.min.js'
//= require 'plugins/jquery.tablesorter.min.js'
//= require 'plugins/jquery.dataTables.min.js'
//= require 'page_specific/decklist.js'

$(document).ready(function(){
  $('.deck-text-trigger').click( function(){
    $('#deckbuilder-list').slideUp( function(){
      $('.deck-text-box').slideDown();
    })
  })
});
