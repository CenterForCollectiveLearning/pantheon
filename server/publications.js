function getCountryExportArgs(begin, end, L, country, occ) {
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
Meteor.publish("peopletop10", function(begin, end, L, country, domain) {
    var sub = this;
    var collectionName = "top10people";

    var args = getCountryExportArgs(begin, end, L, country);

    if (domain.toLowerCase() !== 'all' ) {
        args.$or = [{domain:domain.substring(1)}, {industry:domain.substring(1)}, {occupation:domain.substring(1)}];
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
Also a static query
does not send over anything other than the people ids,
because the whole set of people already exists client side
*/
Meteor.publish("top5occupation", function(begin, end, L, country, industry) {
    var sub = this;
    var args = getCountryExportArgs(begin, end, L, country);
    args.industry = industry;

    People.find(args, {
        fields: { _id: 1 },
        limit: 5,
        sort: { numlangs: -1 }
    }).forEach(function (person) {
        sub.added("mouseoverCollection", person._id, {}) // No other fields in this
    });
    sub.ready();

    // No stop needed here
});

// TODO double check this indexing
People._ensureIndex({ birthyear: 1, countryCode: 1,  occupation: 1} )
People._ensureIndex({ countryCode: 1, occupation: 1, birthyear: 1} )
Imports._ensureIndex({ birthyear: 1, countryCode: 1,  occupation: 1} )
Imports._ensureIndex({ continentName:1, countryCode: 1, occupation: 1, birthyear: 1} )
Imports._ensureIndex({ lang_family: 1, lang: 1, occupation: 1, birthyear: 1} )
Imports._ensureIndex({ category: 1, industry: 1, occupation: 1, birthyear: 1} )

Meteor.publish("scatterplot_pub", function(begin, end, L, countryX, countryY) {
    var sub = this;

    // TODO Combine into a single query
    // TODO Pre-aggregate as in the treemap publication
    var argsX = getCountryExportArgs(begin, end, L, countryX);
    var argsY = getCountryExportArgs(begin, end, L, countryY);
    People.find(argsX).forEach(function (person) {
        sub.added("scatterplot", person._id, person);
    });
    People.find(argsY).forEach(function (person) {
        sub.added("scatterplot", person._id, person);
    });
    sub.ready();
});

/*
 * Static query that pushes the treemap structure
 * This needs to run a native mongo query due to aggregates being not supported directly yet
 */
Meteor.publish("treemap_pub", function(vizMode, begin, end, L, country, language, domain) {
    var sub = this;
    var driver = MongoInternals.defaultRemoteCollectionDriver();

    // TODO modify this query to be more general

    var matchArgs = {
        numlangs: {$gt: L},
        birthyear: {$gte: begin, $lte:end}
    };

    if (country !== 'all' ) {
        matchArgs.countryCode = country;
    };

    if (language !== 'all' ) {
        matchArgs.lang = language;
    };

    if (domain.toLowerCase() !== 'all' ) {
        matchArgs.$or = [{domain :domain.substring(1)}, {industry:domain.substring(1)}, {occupation:domain.substring(1)}];
    };

    var pipeline = [];

    if(vizMode === 'country_exports' || vizMode === 'country_imports' || vizMode === 'bilateral_exporters_of'){
        pipeline = [
            { $match: matchArgs },
            {"$group": { _id: {domain: "$category", industry: "$industry", occupation: "$occupation"},
                "people": { "$addToSet": '$en_curid'}}},
            {"$unwind":"$people"},{"$group": { "_id": "$_id", "count": { "$sum":1} }},
        ];
        driver.mongo.db.collection("imports").aggregate(
            pipeline,
            Meteor.bindEnvironment(
                function(err, result) {

                    _.each(result, function(e) {
                        // Generate a random disposable id for each aggregate
                        sub.added("treemap", Random.id(), {
                            domain: e._id.domain,
                            industry: e._id.industry,
                            occupation: e._id.occupation,
                            count: e.count
                        });
                    });

                    sub.ready();
                },
                function(error) {
                    Meteor._debug( "Error doing aggregation: " + error);
                }
            )
        );
    }
    else if(vizMode === 'domain_exports_to'){
        pipeline = [
            {$match: matchArgs },
            {$group: {
                _id: {continent: "$continentName", countryCode: "$countryCode", countryName: "$countryName"},
                count: {$sum: 1 }
            }}
        ];
        driver.mongo.db.collection("people").aggregate(  //TODO: or count unique en_curid from imports, why is there a difference of one person???
            pipeline,
            Meteor.bindEnvironment(
                function(err, result) {

                    _.each(result, function(e) {
                        // Generate a random disposable id for each aggregate
                        sub.added("treemap", Random.id(), {
                            continent: e._id.continent,
                            countryCode: e._id.countryCode,
                            countryName: e._id.countryName,
                            count: e.count
                        });
                    });

                    sub.ready();
                },
                function(error) {
                    Meteor._debug( "Error doing aggregation: " + error);
                }
            )
        );
    }
    else if(vizMode === 'domain_imports_from' || vizMode === 'bilateral_importers_of'){
        pipeline = [
            {$match: matchArgs },
            {"$group": { _id: {lang_family: "$lang_family", lang: "$lang", lang_name: "$lang_name"},
                "people": { "$addToSet": '$en_curid'}}},
            {"$unwind":"$people"},{"$group": { "_id": "$_id", "count": { "$sum":1} }}
        ];
        driver.mongo.db.collection("imports").aggregate(
            pipeline,
            Meteor.bindEnvironment(
                function(err, result) {

                    _.each(result, function(e) {
                        // Generate a random disposable id for each aggregate
                        sub.added("treemap", Random.id(), {
                            lang_family: e._id.lang_family,
                            lang: e._id.lang,
                            lang_name: e._id.lang_name,
                            count: e.count
                        });
                    });

                    sub.ready();
                },
                function(error) {
                    Meteor._debug( "Error doing aggregation: " + error);
                }
            )
        );
    }
    ;

});