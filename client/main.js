// Set Defaults
// TODO Where do you put these global functions?


// Enable caching for getting readrboard script
jQuery.cachedScript = function( url, options ) {
  // Allow user to set any option except for dataType, cache, and url
  options = $.extend( options || {}, {
    dataType: "script",
    cache: true,
    url: url
  });
 
  // Use $.ajax() since it is more flexible than $.getScript
  // Return the jqXHR object so we can chain callbacks
  return jQuery.ajax( options );
};

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
    Session.setDefault('showTooltip', false);

    // http://stackoverflow.com/questions/14185248/rerendering-meteor-js-on-window-resize
    $(window).resize(function(evt) {
        Session.set("touch", new Date());
        console.log(Session.get("touch"));
    });
});

// Select sections based on template
Template.nav.selected = function() {
    return Session.equals('page', this._id) ? 'selected_section' : '';
}

// Section Navigation
// TODO Is this repetitiveness necessary for correct formatting?
var left_sections = [
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
        section: "Data",
        template: "data",
        url: "/data"
    },
]

var right_sections = [
    {
        section: "Vision",
        template: "vision",
        url: "/vision"
    },
    {
        section: "Publications",
        template: "publications",
        url: "/publications"
    },
    {
        section: "FAQ",
        template: "faq",
        url: "/faq"
    },
    {
        section: "Team",
        template: "about",
        url: "/about"
    }
]

var sections = left_sections.concat(right_sections);

console.log(sections);

Template.nav.helpers({
    left_sections: left_sections,
    right_sections: right_sections,
    sections: sections
})

Template.section.helpers({
    selected: function() {
        return Session.equals('page', this.template) ? 'selected_section' : '';
    }
})

// Template.nav.events = {
//     "mouseenter .main_nav a": function(d) {
//         $(d.target).css('color', 'white');
//     },

//     "mouseleave .main_nav a": function(d) {
//         $(d.target).css('color', '#cccccc');
//     },
// }