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
  $(jquerySelectorString).each(function() {
    $this = $(this);
	$('option', $this).each(function() {
	  $(this).attr('data-iconurl', "/assets/Icons/Classes/" + $(this).attr('class') + "_Icon.gif");
	});
	$this.selectBoxIt({ autoWidth: false });
  });
};

/**
 * Initialize all toggle buttons on the screen
 */
app.UI.initToggleButtons = function() {


  var buttons = $('input[rel="toggle-btn"]');
  buttons.css({
    display:'inline-block'
  });

  // loop through each toggle button and initialize it based on its own settings
  buttons.each(function() {
    var $this = $(this);

    var onClass = $this.attr('onClass') || 'green';
    var offClass = $this.attr('offClass') || 'blue';

    var isOn = $this.attr('state') != "off";
    var onText = $this.attr('on');
    var offText = $this.attr('off');
    var onValue = $this.attr('onValue');
    var offValue = $this.attr('offValue');

    $this.after('<div class="btn ' + $this.attr('class') + ' ' + (isOn ? onClass : offClass) + '"></div>');
    var button = $this.next();
    var isCheckbox = $this.attr('type') == 'checkbox';
    $this.attr('type', "hidden");

    function _applyValue() {
      button.text(isOn ? onText : offText);
      button.text();
      if(isCheckbox) {
        $this[0].value = isOn ? '1' : '0';
      } else {
        $this[0].value = isOn ? onValue : offValue;
      }
    }

    button.click(function() {
      isOn = !isOn;
      button.toggleClass(onClass);
      button.toggleClass(offClass);
      _applyValue();
    });

    _applyValue();
  });
};
