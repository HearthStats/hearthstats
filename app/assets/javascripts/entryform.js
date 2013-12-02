$(document).ready(function(){
  $('.winbutton').click(function(){
    var checked = $('.wincheckbox').prop('checked');
    if ( checked == true )
    {
      $('.winbutton').removeClass('green');
      $('.winbutton').addClass('red');
      $('.wincheckbox').prop('checked', false);
      $('.winbutton').text("Defeat");
      var checked = false;
    }
    else
    {
      $('.winbutton').addClass('green');
      $('.winbutton').removeClass('red');
      $('.wincheckbox').prop('checked', true);
      $('.winbutton').text("Victory");
      var checked = true;
    }
  });
  $('.gofirst').click(function(){
    var checked = $('.firstcheckbox').prop('checked');
    if ( checked == true )
    {
      $('.gofirst').removeClass('green');
      $('.gofirst').addClass('blue');
      $('.firstcheckbox').prop('checked', false);
      $('.gofirst').text("Second Turn");
      var checked = false;
    }
    else
    {
      $('.gofirst').addClass('green');
      $('.gofirst').removeClass('blue');
      $('.firstcheckbox').prop('checked', true);
      $('.gofirst').text("First Turn");
      var checked = true;
    }
  });
  $('.gofirstquick').click(function(){
    var checked = $('.firstcheckbox').prop('checked');
    if ( checked == true )
    {
      $('.gofirstquick').removeClass('green');
      $('.gofirstquick').addClass('blue');
      $('.firstcheckbox').prop('checked', false);
      $('.gofirstquick').text("Coin");
      var checked = false;
    }
    else
    {
      $('.gofirstquick').addClass('green');
      $('.gofirstquick').removeClass('blue');
      $('.firstcheckbox').prop('checked', true);
      $('.gofirstquick').text("No Coin");
      var checked = true;
    }
  });
  // $('.quickentry').click(function() {
  // 	$('.newentry').slideToggle(400);
  // });
});