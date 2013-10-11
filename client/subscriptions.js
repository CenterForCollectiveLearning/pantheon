// These are static data that never change
Meteor.subscribe("countries_pub");
Meteor.subscribe("languages_pub");
Meteor.subscribe("domains_pub");


// These subscriptions are explicitly global variables
this.allpeopleSub = Meteor.subscribe("allpeople");


// These are client only collections
PeopleTop10 = new Meteor.Collection("top10people");
Treemap = new Meteor.Collection("treemap");
Tooltips = new Meteor.Collection("mouseoverCollection");

this.top10Sub = null;
this.treemapSub = null;
this.tooltipSub = null;

Deps.autorun(function(){
    // TODO this only works for exports right now
    // maybe look at how the routes are being updated ...

    var country = Session.get('country');
    var language = Session.get('language');
    var begin = parseInt(Session.get('from'));
    var end = parseInt(Session.get('to'));
    var langs = parseInt(Session.get('langs'));
    var domain = Session.get('domain');
    if(domain){
        domain = domain.toUpperCase();
    }
    var occ = Session.get('occ');
    var vizMode = Session.get('vizMode');

    // TODO this is causing a double subscription, fix me

    if( !country || !begin || !end || !langs ) {
        if( top10Sub !== null ) {
            top10Sub.stop();
            top10Sub = null;
        }
        if( treemapSub !== null ){
            treemapSub.stop();
            treemapSub = null;
        }
    }
    else {
        top10sub = Meteor.subscribe("peopletop10", begin, end, langs, country, domain);
        // Give a handle to this subscription so we can check if it's ready
        treemapSub = Meteor.subscribe("treemap_pub", vizMode, begin, end, langs, country, language, domain);
        console.log("vizMode: "+vizMode);
        console.log("begin: "+begin);
        console.log("end: "+end);
        console.log("L: "+langs);
        console.log("country: "+country);
        console.log("language: "+language);
        console.log("domain: "+domain);

        Session.set("treemapReady", false);

        // Make a throwaway autorun function that listens for the handle being ready
        Deps.autorun(function(c) {
            if (!treemapSub.ready()) return;
            Session.set("treemapReady", true);
            c.stop(); // Need to do this or will get infinite number of autorun functions
        });
    }

});



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
