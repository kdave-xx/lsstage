document.observe('dom:loaded', function() {
  $$('.pricing_option').each(function(p) {
    p.observe('click', did_click_pricing_option);
  });
  
  prize_value = $('competition_prize_value').value;
  selected = false;
  
  $$('input[name=pricing_option]').each(function(r) {
    r.observe('click', did_click_pricing_option);
    if (r.value == prize_value) {
      selected = true;
      did_select_element(r);
    }
  });
  
  if (!selected && prize_value != 0) {
    did_select_element($('custom_pricing_option'));
  }
  
});

function clear_existing_style() {
  $$('a.pricing_option').each(function(p) {
    p.removeClassName('pricing_option_selected');
    if (p.down('div.custom')) {
      p.down('div.custom').hide();
    }
  });
}

function did_click_pricing_option(e) {
  clear_existing_style();
  element = Event.element(e);  
  did_select_element(element);
}

function did_select_element(element) {
  root_element = element.up('a.pricing_option');
  
  if (!root_element) {
    root_element = element;
  }
  custom_price = root_element.down('div.custom');
  radio_button = root_element.down('input');
  hidden_value_field = $('competition_prize_value');
  
  radio_button.checked = true;
  root_element.addClassName('pricing_option_selected')
  if (custom_price) {
    custom_price.show();
  }
  else {
    hidden_value_field.value = radio_button.value;
  }
}