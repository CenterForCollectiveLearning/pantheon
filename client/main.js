Meteor.subscribe("people");

if (typeof Handlebars !== 'undefined') {
  Handlebars.registerHelper('afterBody', function(name, options) {
    $("#accordion")
      .css("opacity", 1)
      .css("height", "100%")
      .accordion({
        active: 0,
        collapsible:true,
        heightStyle:"content",
        fillSpace:true
      });
    
    $("#accordion").accordion( "resize" );
  });
}