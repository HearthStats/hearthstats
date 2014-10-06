$(document).ready(function(){
  $.fn.dataTableExt.sErrMode = 'throw';
  $('[rel="tooltip"]').tooltip();

  $('#decklist').dataTable( {
    "aaSorting": [[ 4, "desc" ]],
    "bPaginate": false
  } );

  $("#merge-toggle").click(function(){
    $(".merge-boxes, #decklist thead tr th:first-child, #merge-button").fadeToggle();
  });

});
