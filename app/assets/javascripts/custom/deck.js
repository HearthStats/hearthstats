$(document).ready(function(){
  $('.deck-text-trigger').click( function(){
    $('#deckbuilder-list').slideUp( function(){
      $('.deck-text-box').slideDown();
    })
  })
});
