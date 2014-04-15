$(document).ready(function(){
	$.fn.dataTableExt.sErrMode = 'throw';
	$('[rel="tooltip"]').tooltip();

	$('#decklist').dataTable( {
	  "aaSorting": [[ 4, "desc" ]],
	  "bPaginate": false
	} );
});