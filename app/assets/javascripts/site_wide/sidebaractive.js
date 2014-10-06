$(document).ready(function(){
  var image = $('.active').attr("data-activeimg")
  $('.active').find('.sidebaricon').attr('src', "/assets/"+ image+".png");
  $('.redactor').each(function(i, elem) {
    $(elem).wysihtml5({
      toolbar: {
        "font-styles": true, //Font styling, e.g. h1, h2, etc. Default true
        "emphasis": true, //Italics, bold, etc. Default true
        "lists": true, //(Un)ordered lists, e.g. Bullets, Numbers. Default true
        "html": false, //Button which allows you to edit the generated HTML. Default false
        "link": true, //Button to insert a link. Default true
        "image": true, //Button to insert an image. Default true,
        "color": true, //Button to change color of font  
        "blockquote": false, //Blockquote  
      }
    });
  });

});
