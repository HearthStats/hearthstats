$(document).ready(function(){
  $('#public_match').click(function(){
    $('#opponent').slideToggle(this.unchecked);
  });

  // Scroll to position function
  (function($) {
    $.fn.goTo = function() {
      $('html, body').animate({
        scrollTop: $(this).offset().top + 'px'
      }, 'fast');
      return this; // for chaining...
    }
  })(jQuery);
});
