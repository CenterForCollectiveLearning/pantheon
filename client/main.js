// Set Defaults
// TODO Where do you put these global functions?

this.defaults = {
    vizType: 'treemap'
    , vizMode: 'country_exports'
    , country: 'all'
    , countryX: 'US'
    , countryY: 'RU'
    , language: 'all'
    , languageX: 'en'
    , languageY: 'fr'
    , domain: 'all'
    , from: '-1000'
    , to: '1950'
    , langs: '25'
    , entity: 'countries'
}

this.IOMapping = {
    "country_exports": { "in": ["country", "language"], "out": "domain" }
    , "country_imports": { "in": ["language", "country"], "out": "domain" }
    , "domain_exports_to": { "in": ["domain", "language"], "out": "country" }
    , "domain_imports_from": { "in": ["domain", "country"], "out": "language" }
    , "bilateral_exporters_of": { "in": ["country", "language"], "out": "domain"}
    , "bilateral_importers_of": { "in": ["country", "domain"], "out": "language"}
    , "matrix_exports": { "in": ["country", "domain"], "out": "language"}
    , "country_vs_country": { "in": ["countryX", "countryY"], "out": "domain"}
    , "lang_vs_lang": { "in": ["languageX", "languageY"], "out": "domain"}
    , "map": { "in": ["domain", "language"], "out": "country" }
}

Meteor.startup(function() {
    Session.setDefault('page', 'observatory');
    Session.setDefault('vizType', defaults.vizType);
    Session.setDefault('vizMode', defaults.vizMode);
    Session.setDefault('country', defaults.country);
    Session.setDefault('countryX', defaults.countryX);
    Session.setDefault('countryY', defaults.countryY);
    Session.setDefault('language', defaults.language);
    Session.setDefault('languageX', defaults.languageX);
    Session.setDefault('languageY', defaults.languageY);
    Session.setDefault('domain', defaults.domain);
    Session.setDefault('from', defaults.from);
    Session.setDefault('to', defaults.to);
    Session.setDefault('langs', defaults.langs);
    Session.setDefault('gender', 'both');
    Session.setDefault('countryOrder', 'count');
    Session.setDefault('industryOrder', 'count');
    Session.setDefault('occ', 'all');
    });

// Select sections based on template
Template.nav.selected = function() {
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
        section: "Vision",
        template: "vision",
        url: "/vision"
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

Template.nav.events = {
    "mouseenter .main_nav a": function(d) {
        $(d.target).css('color', 'white');
    },

    "mouseleave .main_nav a": function(d) {
        $(d.target).css('color', '#cccccc');
    },
}

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
        zIndex: 2e9, // The z-index (defaults to 2000000000),
        top: 'auto', // Top position relative to parent in px
        left: 'auto' // Left position relative to parent in px
    };
    var target = this.find('.loading');
    var spinner = new Spinner(opts).spin(target);
}