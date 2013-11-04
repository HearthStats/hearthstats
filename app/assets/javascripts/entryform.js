$(document).ready(function(){
$('.winbutton').click(function(){
    var checked = $('.wincheckbox').prop('checked');
    if ( checked == true )
    {
      $('.winbutton').css("background", "rgb(202, 60, 60)" );
      $('.wincheckbox').prop('checked', false);
      $('.winbutton').text("Defeat");
      var checked = false;
    }
    else
    {
      $('.winbutton').css("background", "rgb(28, 184, 65)" );
      $('.wincheckbox').prop('checked', true);
      $('.winbutton').text("Victory");
      var checked = true;
    }
  });
});