$(document).ready(function(){
  $(".turn-details").click(function(){
    turn_num = $(this).attr("id");
    $("#turn" + turn_num).slideToggle();
  });
  $("#open-all").click(function(){
    $(".action").slideToggle();
    if ($(this).html() == "Expand All"){
      newVal = "Collapse All"
    }else{
      newVal = "Expand All"
    }
    $(this).html(newVal);
  });
});
