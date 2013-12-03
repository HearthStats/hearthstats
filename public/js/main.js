$(document).ready(function(){
'use strict';

$('.top-nav li').localScroll();
 
//================ Responsive menu ===================//

$('.top-nav').mobileMenu({
	defaultText: 'Navigation',
	className: 'select-menu',
	subMenuDash: '&ndash;'
});

//==================== Slider js ========================//

$('#main-slider').flexslider({
	animation: "fade"
});

$('#quote-slider').flexslider({
	animation: "slide",
	controlNav: true,
	directionNav: false
});


//==================== Carousel js ========================//

$('.slidewrap').carousel({
	slider: '.slider',
	slide: '.slide',
	slideHed: '.slidehed',
	nextSlide : '.next',
	prevSlide : '.prev',
	addPagination: false,
	addNav : false
});

//==================== Prettyphoto ========================//

$("a[class^='prettyPhoto']").prettyPhoto({theme:'pp_default'});

$('input, textarea').placeholder();

//==================== Back to top ========================//

$("#back-top").hide();
	
$(function () {
	$(window).scroll(function () {
		if ($(this).scrollTop() > 100) {
			$('#back-top').fadeIn();
		} else {
			$('#back-top').fadeOut();
		}
	});

	$('#back-top a').click(function () {
		$('body,html').animate({
			scrollTop: 0
		}, 800);
		return false;
	});
});

});

