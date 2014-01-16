// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require jquery.ui.tooltip
//= require select2
//= require social-share-button
//= require nprogress
//= require nprogress-turbolinks
//= require redactor-rails
//= require_tree .
//= require turbolinks

$(document).ready(function(){
	$('.notifications').delay(500).slideDown('normal', function() {
    $(this).delay(2500).slideUp();
  });
  NProgress.configure({
	  showSpinner: false,
	  ease: 'ease',
	  speed: 500
	});
  // send get forms through turbolinks
  $(document).on("submit", "form.data-turboform", function(e) {
    Turbolinks.visit(this.action+(this.action.indexOf('?') == -1 ? '?' : '&')+$(this).serialize());
    return false;
  });
});

// define a global app object to store easily accessible common methods
var app = app || {};

// define UI namespace/object
app.UI = app.UI || {};

/**
 * Initialize a select element of Hearthstone classes 
 * 
 * @param {string} jquerySelectorText The string you  
 * would pass to jQuery to select a DOM element
 */
app.UI.initClassSelector = function(jquerySelectorString) {
	$(jquerySelectorString + ' option').each(function() {
		$(this).attr('data-iconurl', "/assets/Icons/Classes/" + $(this).text() + "_Icon.gif");
	});
	$(jquerySelectorString).selectBoxIt();
};

/**
 * Initialize a select element of Hearthstone decks 
 * 
 * @param {string} jquerySelectorText The string you  
 * would pass to jQuery to select a DOM element
 */
app.UI.initDeckSelector = function(jquerySelectorString) {
	$(jquerySelectorString + ' option').each(function() {
		$(this).attr('data-iconurl', "/assets/Icons/Classes/" + $(this).attr('class') + "_Icon.gif");
	});
	$(jquerySelectorString).selectBoxIt();
};
