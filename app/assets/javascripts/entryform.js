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
      $('.winbutton').css("background", "rgb(53, 170, 71)" );
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
      $('.gofirst').text("Second Turn");
      var checked = false;
    }
    else
    {
      $('.gofirst').css("background", "rgb(53, 170, 71)" );
      $('.firstcheckbox').prop('checked', true);
      $('.gofirst').text("First Turn");
      var checked = true;
    }
  });
  $('.gofirstquick').click(function(){
    var checked = $('.firstcheckbox').prop('checked');
    if ( checked == true )
    {
      $('.gofirstquick').css("background", "rgb(66, 184, 221)" );
      $('.firstcheckbox').prop('checked', false);
      $('.gofirstquick').text("Coin");
      var checked = false;
    }
    else
    {
      $('.gofirstquick').css("background", "rgb(53, 170, 71)" );
      $('.firstcheckbox').prop('checked', true);
      $('.gofirstquick').text("No Coin");
      var checked = true;
    }
  });
  // $('.quickentry').click(function() {
  // 	$('.newentry').slideToggle(400);
  // });
});