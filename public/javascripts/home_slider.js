var slideshow_count = 2;
var current_slide = 0;

$(document).observe('dom:loaded', function() {
  new PeriodicalExecuter(did_click_slide_link, 3);
});

function slide_to_position(e) {
  var offsets = $(e).positionedOffset();
  var total_width = $(e).getWidth();
  var slideshow_width = total_width / slideshow_count;

  var slide_to_position = -(current_slide * slideshow_width);
  new Effect.Move($(e), { x: slide_to_position, y: 0, mode: 'absolute', transition: Effect.Transitions.sinoidal, duration: 0.5, queue: { scope: 'slide' }});
}

function cancel_slider_animation(){
  Effect.Queues.get('home_slider').each(function(effect) { effect.cancel(); });
}

function slide_to_next() {
  cancel_slider_animation();

  current_slide += 1;
  if (current_slide >= slideshow_count){ 
    current_slide = 0;
  }

  slide_to_position('slide');
}

function did_click_slide_link(e){
  slide_to_next();
  Event.stop(e);
}
