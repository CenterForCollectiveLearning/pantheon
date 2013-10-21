function getCountryExportArgs(begin, end, L, country, category, categoryLevel) {
    var args = {
        birthyear : {$gt:begin, $lte:end}
        , numlangs: {$gt: L}
    };
    if (country !== 'all' ) {
        args.countryCode = country;
    }
    if (category !== undefined && occ !== 'all') {
        args[categoryLevel] = category;
    }
    return args;
}

Meteor.publish("countries_pub", function() {
    return Countries.find();
});

Meteor.publish("domains_pub", function(){
    return Domains.find();
})

Meteor.publish("languages_pub", function() {
    return Languages.find();
});

/*
    Publish the top 10 people for the current query
    This is a static query since the query doesn't ever change for some given parameters
    Push the ids here as well since people will be in the client side
 */
Meteor.publish("peopletop10", function(begin, end, L, country, category, categoryLevel) {
    var sub = this;
    var collectionName = "top10people";

    var args = getCountryExportArgs(begin, end, L, country);

    if (category.toLowerCase() !== 'all' ) {
        args[categoryLevel] = category;
    };

    People.find(args, {
        fields: {_id: 1}, //only get the ids of the people - look up the people in the client (from allpeople)
        limit: 10,
        sort: {numlangs: -1}
    }).forEach(function(person){
        sub.added(collectionName, person._id, person);
    });

    sub.ready();

    return;
});

/*
 Publish the top N people for the current query
 This is a static query since the query doesn't ever change for some given parameters
 Push the ids here as well since people will be in the client side
 */
Meteor.publish("peopletopN", function(begin, end, L, country, category, categoryLevel, N) {
    var sub = this;
    var collectionName = "topNpeople";

    var criteria = getCountryExportArgs(begin, end, L, country);

    var projection = {};

    if(N !== 'all'){
        projection.limit = N;
    }

    if (category.toLowerCase() !== 'all' ) {
        criteria[categoryLevel] = category;
    };

    console.log("CRITERIA: ");
    console.log(criteria);
    console.log("PROJECTION: ");
    console.log(projection);

    People.find(criteria, projection).forEach(function(person){
            sub.added(collectionName, person._id, person);
        });

    sub.ready();

    return;
});

/*
    Publish five people (+/- two) given a rank and either a country, domain, or birthyear range.
    TODO: How do you do this correctly?X1
 */
Meteor.publish("fivepeoplebyrank", function(begin, end, L, country, domain) {
    var sub = this;
    var collectionName = "fivepeople";

    var args  = getCountryExportArgs(begin, end, L, country);

    sub.ready();

    return
})

/*
This is also a static query
Compare to doing People.find(),
this just pushes all the people and forgets about them
and does not incur the overhead of a mongo observe()
*/
Meteor.publish("allpeople", function() {
    var sub = this;

    People.find().forEach(function(person) {
        sub.added("people", person._id, person)
    });

    sub.ready();
    // No stop needed here
});

/*
Pass top five people to populate people

Also a static query
does not send over anything other than the people ids,
because the whole set of people already exists client side
*/
Meteor.publish("tooltipPeople", function(vizMode, begin, end, L, country, countryX, countryY, gender, category, categoryLevel) {
    var sub = this;

    var args = {
        birthyear : {$gt:begin, $lte:end}
        , numlangs: {$gt: L}
    };

    if (category.toLowerCase() !== 'all' ) {
        args[categoryLevel] = category;
    }

    if (vizMode === "country_exports" || vizMode === "matrix_exports" || vizMode == "domain_exports_to" || vizMode === "map") {
        if (country !== 'all' ) {
            args.countryCode = country;
        }
    } else if (vizMode === "country_vs_country") {
        args.$or = [{countryCode: countryX}, {countryCode: countryY}]
    }

    var projection = {_id: 1};
    var limit = 5;
    var sort = {numlangs: -1};

    // Get people
    People.find(args, {
        fields: projection, 
        limit: limit, 
        sort: sort,
        hint: occupation_countryCode}).forEach(function(person){
            sub.added("tooltipCollection", person._id, {});
         });

    // Get count
    var count = People.find(args, {
        fields: projection,
        hint: occupation_countryCode}).count();
    sub.added("tooltipCollection", 'count', {count: count});

    return;
});