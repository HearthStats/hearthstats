$(document).ready(function(){
  $(".turn-details").click(function(){
    turn_num = $(this).attr("id");
    console.log(turn_num);
    $("#turn" + turn_num).slideToggle();
  });
});