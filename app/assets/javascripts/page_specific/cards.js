//= require 'plugins/jquery.lazyload.min.js'

$(function() {
  function imgError(image) {
    image.onerror = "";
    image.src = "/images/noimage.gif";
    return true;
  }
  $("img.lazy-load").lazyload();
  $('#cardsFilter select').change(function() {
    $('#cardsFilter').submit();
  });
  $('#cardsFilterSubmit').hide();
  $('#cardsFilterReset').click(function() {
    document.location = "cards";
  });
});
