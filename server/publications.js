Meteor.publish("countries", function() {
    return Countries.find();
});

/*
    Publish the top 10 people for the current query
    This is a static query since the query doesn't ever change for some given parameters
    Push the ids here as well since people will be in the client side
 */
Meteor.publish("peopletop10", function(begin, end, L, country) {
    var sub = this;
    var collectionName = "top10people";

    var args = {
        birthyear : {$gt:begin, $lte:end}
    };
    if (country !== 'all' ) {
        args.countryCode = country;
    }

    top10peopleHandle = People.find(args, {sort: {numlangs: -1}, limit: 10}).observe({
        added: function(person) {
            sub.added(collectionName, person._id, person);
        },
        removed: function(person) {
            sub.removed(collectionName, person._id);
        }
    });

    sub.ready();

    return; //TODO: add sort by numlangs
});

function getCountryExportArgs(begin, end, L, country, occ) {
// TODO: Publish smarter
// Meteor.publish("people", function() {
//     return People.find();
// });

Meteor.publish("people", function(begin, end, L, country, occ){
    var args = {
        birthyear : {$gt:begin, $lte:end}
    };
    if (country !== 'all' ) {
        args.countryCode = country;
    }
    if (occ !== undefined && occ !== 'all') {
        args.occupation = occ;
    }
    return args;
}

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

<<<<<<< Updated upstream
/*
Also a static query
does not send over anything other than the people ids,
because the whole set of people already exists client side
*/
Meteor.publish("top5occupation", function(begin, end, L, country) {
    var sub = this();
    var args = getCountryExportArgs(begin, end, L, country);
    People.find(args, {
        fields: { _id: 1 },
        limit: 5,
        sort: { numlangs: -1 }
    }).forEach(function (person) {
    sub.added("mouseoverCollection", person._id, {}) // No other fields in this
    });
    sub.ready();
    // No stop needed here
    return People.find(args); //TODO: add sort by numlangs
});

// TODO double check this indexing
People._ensureIndex({ birthyear: 1, countryCode: 1,  occupation: 1} )

/*
 * Static query that pushes the treemap structure
 * This needs to run a native mongo query due to aggregates being not supported directly yet
 */
 Meteor.publish("domain", function(begin, end, L, country) {
    var sub = this;
    var driver = MongoInternals.defaultRemoteCollectionDriver;

    // We need a future here because Meteor functions are synchronous
    var future = new Future;
    var callback = future.resolver();

    // TODO modify this query to be more general
    // and in a format that can be directly passed to d3.nest

    driver.db.collection("people").aggregate(
        // TODO: need to update this to count distinct name/en_curid
        {"$match": {"countryCode": cc, "numlangs": {"$gt": nlangs}, "birthyear": {"$gte": begin, "$lte":end}}},
        {"$group": {"_id": {"category": "$category", "industry": "$industry"}, "count": {"$sum": 1 }}}
        , callback);

    var results = future.wait();

    _.each(results, function(e) {
        // Generate a random disposable id for each aggregate
        sub.added("domain", Random.id(), e)
    });

    sub.ready();
});