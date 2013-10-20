// Set Defaults



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
    , domain: 'all'
    , domainX: '+ARTS'
    , domainY: '+HUMANITIES'
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
    , "domain_vs_domain": { "in": ["domainX", "domainY"], "out": "country"}
    , "lang_vs_lang": { "in": ["languageX", "languageY"], "out": "domain"}
    , "map": { "in": ["domain", "language"], "out": "country" }
}

// Object containing domain hierarchy for domains dropdown
this.uniqueDomains = [];
this.indByDom = {}
this.occByInd = {}

Meteor.startup(function() {
    _.each(Domains.find().fetch(), function(domain_obj) {
    var domain = domain_obj.domain
    var industry = domain_obj.industry;
    var occupation = domain_obj.occupation;

    if (uniqueDomains.indexOf(domain) == -1)
        uniqueDomains.push(domain);

    if (!indByDom.hasOwnProperty(domain))
        indByDom[domain] = [industry];
    else {
        if (indByDom[domain].indexOf(industry) == -1)
            indByDom[domain].push(industry);
    }

    if (!occByInd.hasOwnProperty(industry))
        occByInd[industry] = [occupation];
    else
        occByInd[industry].push(occupation);
})
    
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
    Session.setDefault('domainX', defaults.domainX);
    Session.setDefault('domainY', defaults.domainY);
    Session.setDefault('from', defaults.from);
    Session.setDefault('to', defaults.to);
    Session.setDefault('langs', defaults.langs);
    Session.setDefault('occ', 'all');

    // MATRICES
    Session.setDefault('gender', 'both');
    Session.setDefault('countryOrder', 'count');
    Session.setDefault('industryOrder', 'count');
    

    // TOOLTIPS
    Session.setDefault('showTooltip', false);
    Session.setDefault('tooltipDomainAggregation', 'industry')

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