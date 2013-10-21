/*
 * Static query that pushes the treemap structure
 * This needs to run a native mongo query due to aggregates being not supported directly yet
 */
Meteor.publish("treemap_pub", function(vizMode, begin, end, L, country, language, category, categoryLevel) {
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

    console.log(category);

    if (category.toLowerCase() !== 'all' ) {
        matchArgs[categoryLevel] = category;
    };

    var pipeline = [];

    if(vizMode === 'country_exports'){
        pipeline = [
            {$match: matchArgs },
            {$group: {
                _id: {domain: "$domain", industry: "$industry", occupation: "$occupation"},
                count: {$sum: 1 }
            }}
        ];
        driver.mongo.db.collection("people").aggregate(
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
    else if(vizMode === 'country_imports' || vizMode === 'bilateral_exporters_of'){
        console.log(matchArgs);
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
        driver.mongo.db.collection("people").aggregate(
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
    };

});