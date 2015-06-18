//= require 'plugins/flot/jquery.flot.min.js'
//= require 'plugins/flot/jquery.flot.pie.min.js'
//= require 'plugins/jquery.easy-pie-chart.js'
//= require 'plugins/jquery.selectBoxIt.js'
//= require 'site_wide/app.js'
//= require 'plugins/jquery.tagsinput.min.js'
//= require 'plugins/jquery.tablesorter.min.js'
//= require 'plugins/jquery.mixitup.min.js'
//= require 'plugins/jquery.dataTables.min.js'
//= require 'page_specific/decklist.js'
//= require 'plugins/jquery.lazyload.min.js'
//= require react
//= require react_ujs
//= require components

$(document).ready(function(){
  $('.deck-text-trigger').click( function(){
    $('#deckbuilder-list').slideUp( function(){
      $('.deck-text-box').slideDown();
    })
  })
  $('.create-archtype').click( function(){
    $('.archtype-dropdown').slideUp( function(){
      $('.new-archtype-input').slideDown();
    })
  })
  $('[data-toggle="popover"]').popover({
    trigger: "hover",
    placement: "top"
  })
  $('#show-archived').click( function(){
    $('.archived').slideToggle();
  });
  $('.easy-pie-chart .win_rate.overall').easyPieChart({
    animate: 1000,
    size: 75,
    lineWidth: 3,
    barColor: App.getLayoutColorCode('yellow')
  });
  $('.easy-pie-chart .win_rate.no_coin').easyPieChart({
    animate: 1000,
    size: 75,
    lineWidth: 3,
    barColor: App.getLayoutColorCode('red')
  });
  $('.easy-pie-chart .win_rate.coin').easyPieChart({
    animate: 1000,
    size: 75,
    lineWidth: 3,
    barColor: App.getLayoutColorCode('green')
  });
});
