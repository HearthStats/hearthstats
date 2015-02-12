(function ($) {

	jQuery(window).load(function() { 
		jQuery("#preloader").delay(100).fadeOut("slow");
		jQuery("#load").delay(100).fadeOut("slow");
	});


	//jQuery for page scrolling feature - requires jQuery Easing plugin
	$(function() {
		$('.page-scroll a').bind('click', function(event) {
			var $anchor = $(this);
			$('html, body').stop().animate({
				scrollTop: $($anchor.attr('href')).offset().top
			}, 1500, 'easeInOutExpo');
			event.preventDefault();
		});
	});

	// Honorable Mentions
	// $(".honor-card-win").mouseover(function() {
	// 	cardName = $(this).data("name");
	// 	$(".win-img").attr("src", "/reports/gvg/img/cards/" + cardName + ".png")
	// });
	// $(".honor-card-count").mouseover(function() {
	// 	cardName = $(this).data("name");
	// 	$(".count-img").attr("src", "/reports/gvg/img/cards/" + cardName + ".png")
	// });

	// Mode Matrix
	$('.matrix-btn').click(function(){
		mode = $(this).data("mode")
		$('.matrix-btn').removeClass("active");
		$(this).addClass("active");
		$(".mode-matrix").slideUp(function(){
			$("." + mode).slideDown();			
		});
	});
})(jQuery);
