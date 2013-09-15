// Set Defaults
Meteor.startup(function() {
    Session.setDefault('page', 'observatory')
    Session.setDefault('vizType', 'treemap')
    Session.setDefault('vizMode', 'country_exports')
    Session.setDefault('ent1', 'all')
    Session.setDefault('ent2', 'all')
    Session.setDefault('from', '-1000')
    Session.setDefault('to', '1950')
    Session.setDefault('langs', '25')
    });

Template.nav.events = {
    // TODO is this really necessary?
    "click .main_nav a": function (event) {
        var anchor = $(this);

        $('html, body').stop().animate({
            scrollTop: $(anchor.attr('href')).offset().top
        }, 900, 'easeInOutExpo');

        event.preventDefault();
    }
}

// Global Helper
if (typeof Handlebars !== 'undefined') {
  Handlebars.registerHelper('afterBody', function(name, options) {
  });
}

// Select sections based on template
// Template.nav.selected = function() {
//     return Session.equals('page', this._id) ? 'selected_section' : '';
// }

// Spinner
Template.spinner.rendered = function(){
    var opts = {
        lines: 12, // The number of lines to draw
        length: 6, // The length of each line
        width: 3, // The line thickness
        radius: 6, // The radius of the inner circle
        corners: 1, // Corner roundness (0..1)
        rotate: 0, // The rotation offset
        direction: 1, // 1: clockwise, -1: counterclockwise
        color: '#fff', // #rgb or #rrggbb
        speed: 1, // Rounds per second
        trail: 60, // Afterglow percentage
        shadow: false, // Whether to render a shadow
        hwaccel: false, // Whether to use hardware acceleration
        className: 'spinner', // The CSS class to assign to the spinner
        zIndex: 2e9, // The z-index (defaults to 2000000000)
        top: 'auto', // Top position relative to parent in px
        left: 'auto' // Left position relative to parent in px
    };
    var target = this.find('.loading');
    var spinner = new Spinner(opts).spin(target);
}