Meteor.subscribe("countries");

// These subscriptions are explicitly global variables
this.allpeopleSub = Meteor.subscribe("allpeople");

PeopleTop10 = new Meteor.Collection("top10people");

this.top10Sub = null;
this.treemapSub = null;

Tooltips = new Meteor.Collection("mouseoverCollection");

this.tooltipSub = null;

Deps.autorun(function(){
    // TODO this only works for exports right now
    // maybe look at how the routes are being updated ...

    var country = Session.get('country');
    var begin = parseInt(Session.get('from'));
    var end = parseInt(Session.get('to'));
    var langs = parseInt(Session.get('langs'));
    var occ = Session.get('occ');

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
        top10sub = Meteor.subscribe("peopletop10", begin, end, langs, country);
        treemapSub = Meteor.subscribe("domain", begin, end, langs, country);
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
    
    tooltipSub = Meteor.subscribe("top5occupation", begin, end, langs, country, Domains.findOne(industry).industry);
})
