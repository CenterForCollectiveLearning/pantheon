Meteor.subscribe("countries");

PeopleTop10 = new Meteor.Collection("top10people");

var top10sub = null;

Deps.autorun(function(){
    var country = Session.get('country');
    var begin = parseInt(Session.get('from'));
    var end = parseInt(Session.get('to'));
    var langs = Session.get('langs');

    if( !country || !begin || !end || !langs ) {
        if( top10sub != null ) {
            top10sub.stop();
        }
    }
    else {
        top10sub = Meteor.subscribe("peopletop10", begin, end, langs, country);
    }
});

// TODO subscribe to people