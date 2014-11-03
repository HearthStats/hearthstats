//= require 'plugins/flot/jquery.flot.min.js'
//= require 'plugins/flot/jquery.flot.time.min.js'

$(document).ready(function(){
  $('#start_date').datepicker(
    { dateFormat: 'yy-mm-dd'}
  );
  $('#end_date').datepicker(
    { dateFormat: 'yy-mm-dd'}
  );
});
