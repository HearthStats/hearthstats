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
  $('.gofirst').click(function(){
    var checked = $('.firstcheckbox').prop('checked');
    if ( checked == true )
    {
      $('.gofirst').css("background", "rgb(66, 184, 221)" );
      $('.firstcheckbox').prop('checked', false);
      $('.gofirst').text("Second");
      var checked = false;
    }
    else
    {
      $('.gofirst').css("background", "rgb(28, 184, 65)" );
      $('.firstcheckbox').prop('checked', true);
      $('.gofirst').text("First");
      var checked = true;
    }
  });
});