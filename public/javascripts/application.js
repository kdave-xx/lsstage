// // Place your application-specific JavaScript functions and classes here
// // This file is automatically included by javascript_include_tag :defaults
// document.observe('dom:loaded', function() {
//   $$('.logo_popup').each(function(i){
//     logo_id = i.readAttribute('alt');
//   
//     new Tip(
//       i,
//       {
//         ajax: {
//           url: '/logos/' + logo_id + '/preview',
//           options: {
//             method: 'get'
//           }
//         },
//         width: 'auto',
//         stem: 'topLeft',
//         viewport: true
//       }
//     );
//   });
// 
// });

jQuery(window).load(function(){
  // The magic sliding panels
 jQuery('.logo').mouseover(function(e){
      jQuery(this).find('div.logo_image').stop().animate({
     marginTop : '-50px'
   }, 100).parent('div.logo').find('p.logo_title').stop().fadeTo("slow",1.0);
 });
 jQuery('.logo').mouseout(function(e){
      jQuery(this).find('div.logo_image').stop().animate({
     marginTop : '0'
   }, 100).parent('div.logo').find('p.logo_title').stop().fadeTo("slow",0.0);
 });
 
  // The magic sliding panels
 jQuery('.person').mouseover(function(e){
      jQuery(this).find('div.person_image').stop().animate({
     marginTop : '-50px'
   }, 100).parent('div.person').find('p.person_title').stop().fadeTo("slow",1.0);
 });
 jQuery('.person').mouseout(function(e){
      jQuery(this).find('div.person_image').stop().animate({
     marginTop : '0'
   }, 100).parent('div.person').find('p.person_title').stop().fadeTo("slow",0.0);
 });
 
});

document.observe('dom:loaded', function() {
  document.observe('click', hide_all_title_menus);
  $$('.title_menu a.menu_link').each(function(l) {
    l.observe('click', toggle_title_menu);
  });
});

function hide_all_title_menus() {
  $$('li div.menu').each(function(m) {
    m.hide();
  });
}

function toggle_title_menu(e) {
  hide_all_title_menus();
  link = Event.element(e);
  Event.stop(e);
  $(link).up('li').down('div.menu').toggle();
}


