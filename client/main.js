// Set Defaults
// TODO Where do you put these global functions?

Meteor.startup(function() {
    Session.setDefault('page', 'observatory');
    Session.setDefault('vizType', 'treemap');
    Session.setDefault('vizMode', 'country_exports');
    Session.setDefault('country', 'all');
    Session.setDefault('language', 'all');
    Session.setDefault('domain', 'all');
    Session.setDefault('from', '-1000');
    Session.setDefault('to', '1950');
    Session.setDefault('langs', '25');
    Session.setDefault('gender', 'both');
    Session.setDefault('countryOrder', 'count');
    Session.setDefault('industryOrder', 'count');
    });

// Select sections based on template
Template.nav.selected = function() {
    console.log(this.id);
    return Session.equals('page', this._id) ? 'selected_section' : '';
}

// Section Navigation
// TODO Is this repetitiveness necessary for correct formatting?
var sections = [
    {
        section: "Observatory",
        template: "observatory",
        url: "/observatory"
    },
    {
        section: "Vision",
        template: "vision",
        url: "/vision"
    },
    {
        section: "Ranking",
        template: "ranking",
        url: "/ranking"
    },
    {
        section: "People",
        template: "people",
        url: "/people"
    },
    {
        section: "Data",
        template: "data",
        url: "/data"
    },
    {
        section: "FAQ",
        template: "faq",
        url: "/faq"
    },
    {
        section: "About",
        template: "about",
        url: "/about"
    }
]

Template.nav.helpers({
    sections: sections
})

Template.section.helpers({
    selected: function() {
        return Session.equals('page', this.template) ? 'selected_section' : '';
    }
})

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