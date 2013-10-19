// These are static data that never change
Meteor.subscribe("countries_pub");
Meteor.subscribe("languages_pub");
Meteor.subscribe("domains_pub");

// These subscriptions are explicitly global variables
allpeopleSub = Meteor.subscribe("allpeople");

// These are client only collections
PeopleTop10 = new Meteor.Collection("top10people");
Treemap = new Meteor.Collection("treemap");
Matrix = new Meteor.Collection("matrix");
Scatterplot = new Meteor.Collection("scatterplot");
WorldMap = new Meteor.Collection("worldmap");
Tooltips = new Meteor.Collection("mouseoverCollection");

var top10Sub = null;
var dataSub = null;
var tooltipSub = null;

/*
Subscription for the current data that is being visualized
 */
Deps.autorun(function(){
    var country = Session.get('country');
    var countryX = Session.get('countryX');
    var countryY = Session.get('countryY');
    var language = Session.get('language');
    var languageX = Session.get('languageX');
    var languageY = Session.get('languageY');
    var begin = parseInt(Session.get('from'));
    var end = parseInt(Session.get('to'));
    var langs = parseInt(Session.get('langs'));
    var domain = Session.get('domain');
    var domainX = Session.get('domainX');
    var domainY = Session.get('domainY');
    var gender = Session.get('gender');
    if(domain){
        domain = domain.toUpperCase();
    }
    var occ = Session.get('occ');
    var vizMode = Session.get('vizMode');

    /*
        TODO this is probably not the right way to check if no data should be loaded.
        Do something more robust.
      */
    if( !country || !begin || !end || !langs ) {
        /*
         Do nothing:

         It's not necessary to track/stop subscriptions (i.e. those below)
          that are called inside an autorun computation.
         See http://docs.meteor.com/#meteor_subscribe

         We verified this by going from map to treemap back to map while checking
          the PeopleTop10 collection on the client. it goes from 0 -> 10 -> 0.
         */
    }
    else {
        Session.set("dataReady", false);
        // This gets passed to the subscriptions to indicate when data is ready
        var onReady = function() {
            Session.set("dataReady", true);
            Session.set("initialDataReady", true);
        };

        // Give a handle to this subscription so we can check if it's ready
        switch(vizMode) {
            // Treemap modes
            case "country_imports":
            case "country_exports":
            case "bilateral_exporters_of":
            case "domain_exports_to":
            case "domain_imports_from":
            case "bilateral_importers_of":
                top10Sub = Meteor.subscribe("peopletop10", begin, end, langs, country, domain);
                dataSub = Meteor.subscribe("treemap_pub", vizMode, begin, end, langs, country, language, domain, onReady);
                break;
            // Matrix modes
            case "matrix_exports":
            console.log("IN MATRIX EXPORTS")
                dataSub = Meteor.subscribe("matrix_pub", begin, end, langs, gender, onReady);
                break
            // Scatterplot modes
            case "country_vs_country":
            case "lang_vs_lang":
            case "domain_vs_domain":
                dataSub = Meteor.subscribe("scatterplot_pub", vizMode, begin, end, langs, countryX, countryY, languageX, languageY, domainX, domainY, onReady);
                break;
            // Map modes
            case "map":
                dataSub = Meteor.subscribe("map_pub", begin, end, langs, domain, onReady);
                break;
            default:
                console.log("Unsupported vizMode");
        }

        console.log("vizMode: "+vizMode);
        console.log("begin: "+begin);
        console.log("end: "+end);
        console.log("L: "+langs);
        console.log("country: "+country);
        console.log("countryX: "+countryX);
        console.log("countryY: "+countryY);
        console.log("languageX: "+languageX);
        console.log("languageY: "+languageY);
        console.log("language: "+language);
        console.log("domain: "+domain);
        console.log("gender: "+gender);
    }
});

/*
 Subscription for tooltips on hover
  */
Deps.autorun(function() {
    var industry = Session.get("tooltipIndustry");

    var country = Session.get('country');
    var begin = parseInt(Session.get('from'));
    var end = parseInt(Session.get('to'));
    var langs = parseInt(Session.get('langs'));

    var occ = Session.get('occ');

    // TODO fix this hack
    if( window.Domains === undefined ) return;

    if( !country || !begin || !end || !langs || !industry ) {
        if( tooltipSub !== null ){
            tooltipSub.stop();
            tooltipSub = null;
        }
    }
    // tooltipSub = Meteor.subscribe("top5occupation", begin, end, langs, country, Domains.findOne(industry).industry);
});
