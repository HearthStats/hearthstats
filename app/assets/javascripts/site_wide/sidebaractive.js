$(document).ready(function(){
  var image = $('.active').attr("data-activeimg")
  $('.active').find('.sidebaricon').attr('src', "/assets/"+ image+".png");
});
