// Set Defaults

this.getCategoryLevel = function(s) {
    var domains = Domains.find().fetch();
    for (i in domains) {
        var domain_obj = domains[i];
        if (domain_obj.domain == s) return "domain";
        if (domain_obj.industry == s) return "industry";
        if (domain_obj.occupation == s) return "occupation";
    }
}

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
    , languageY: 'ru'
    , category: 'all'
    , categoryX: 'ARTS'
    , categoryY: 'HUMANITIES'
    , categoryLevel: 'domain'
    , from: '-1000'
    , to: '1950'
    , langs: '25'
    , entity: 'countries'
}

this.IOMapping = {
    "country_exports": { "in": ["country", "language"], "out": "category" }
    , "country_imports": { "in": ["language", "country"], "out": "category" }
    , "domain_exports_to": { "in": ["category", "language"], "out": "country" }
    , "domain_imports_from": { "in": ["category", "country"], "out": "language" }
    , "bilateral_exporters_of": { "in": ["country", "language"], "out": "category"}
    , "bilateral_importers_of": { "in": ["country", "category"], "out": "language"}
    , "matrix_exports": { "in": ["country", "category"], "out": "language"}
    , "country_vs_country": { "in": ["countryX", "countryY"], "out": "category"}
    , "domain_vs_domain": { "in": ["categoryX", "categoryY"], "out": "country"}
    , "lang_vs_lang": { "in": ["languageX", "languageY"], "out": "category"}
    , "map": { "in": ["category", "language"], "out": "country" }
}

// Object containing domain hierarchy for domains dropdown
this.uniqueDomains = [];
this.indByDom = {}
this.occByInd = {}

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
    Session.setDefault('category', defaults.category);
    Session.setDefault('categoryX', defaults.categoryX);
    Session.setDefault('categoryY', defaults.categoryY);
    Session.setDefault('from', defaults.from);
    Session.setDefault('to', defaults.to);
    Session.setDefault('langs', defaults.langs);
    Session.setDefault('occ', 'all');
    Session.setDefault('categoryLevel', defaults.categoryLevel);

    // MATRICES
    Session.setDefault('gender', 'both');
    Session.setDefault('countryOrder', 'count');
    Session.setDefault('industryOrder', 'count');
    

    // TOOLTIPS
    Session.setDefault('showTooltip', false);
    Session.setDefault('tooltipCategory', 'all')
    Session.setDefault('tooltipCategoryLevel', 'domain')
    Session.setDefault('tooltipCountryCode', 'all')
    Session.setDefault('tooltipCountryCodeX', 'all')
    Session.setDefault('tooltipCountryCodeY', 'all')

    // SPLASH SCREEN
    Session.get("authorized", false);

    // Set session variable if window resized (throttled rate)
    var throttledResize = _.throttle(function(){
        Session.set("resize", new Date())
    }, 50);
    $(window).resize(throttledResize);

    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-44888546-1', 'mit.edu');
  ga('send', 'pageview');
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
        section: "Rankings",
        template: "rankings",
        url: "/ranking"
    },
    // {
    //     section: "People",
    //     template: "people",
    //     url: "/people"
    // },
    {
        section: "Vision",
        template: "vision",
        url: "/vision"
    }

]

var right_sections = [
    {
        section: "Data",
        template: "data",
        url: "/data"
    },
    // {
    //     section: "Publications",
    //     template: "publications",
    //     url: "/publications"
    // },
    {
        section: "FAQ",
        template: "faq",
        url: "/faq"
    },
    {
        section: "Team",
        template: "team",
        url: "/team"
    }
]

Template.nav.helpers({
    left_sections: left_sections
    , right_sections: right_sections
})

Template.section.helpers({
    selected: function() {
        return Session.equals('page', this.template) ? 'selected_section' : '';
    }
})

Template.spinner.rendered = function() {
    $('header').css('border-bottom-width', '0px');
    NProgress.configure({
        minimum: 0.2
        , trickleRate: 0.1
        , trickleSpeed: 500
    })
    NProgress.start();
}

Template.spinner.destroyed = function() {
    NProgress.done();
    $('header').css('border-bottom-width', '3px');
}