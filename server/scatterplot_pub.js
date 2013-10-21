Meteor.publish("scatterplot_pub", function(vizMode, begin, end, L, countryX, countryY, languageX, languageY, domainX, domainY) {
    var sub = this;
    var driver = MongoInternals.defaultRemoteCollectionDriver();

    var matchArgs = {
        numlangs: {$gt: L},
        birthyear: {$gte: begin, $lte:end}
    };

    var pipeline = [];

    var field;
    if (vizMode === 'country_vs_country') {
        matchArgs.$or = [{countryCode: countryX}, {countryCode: countryY}];
        pipeline = 
        [
            { $match: matchArgs },
            {"$group": { _id: {countryCode: "$countryCode", domain: "$category", industry: "$industry", occupation: "$occupation"},
                "people": { "$addToSet": '$en_curid'}}},
            {"$unwind": "$people"},
            {"$group": { "_id": "$_id", "count": { "$sum": 1} }}
        ];
        driver.mongo.db.collection("people").aggregate(
            pipeline,
            Meteor.bindEnvironment(
                function(err, result) {
                    _.each(result, function(e) {
                        // Generate a random disposable id for each aggregate
                        sub.added("scatterplot", Random.id(), {
                            countryCode: e._id.countryCode,
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
    
    } else if (vizMode === 'lang_vs_lang') {
        matchArgs.$or = [{lang: languageX}, {lang: languageY}];
        pipeline = [
            { $match: matchArgs },
            {"$group": { _id: {lang:"$lang", domain: "$category", industry: "$industry", occupation: "$occupation"},
            "people": { "$addToSet": '$en_curid'}}},
            {"$unwind":"$people"},{"$group": { "_id": "$_id", "count": { "$sum":1} }}
            ];
        driver.mongo.db.collection("imports").aggregate(
            pipeline,
            Meteor.bindEnvironment(
                function(err, result) {
                    _.each(result, function(e) {
                        // Generate a random disposable id for each aggregate
                        sub.added("scatterplot", Random.id(), {
                            lang: e._id.lang,
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
    } else if (vizMode === 'domain_vs_domain') {
        matchArgs.$or = [{domain: domainX}, {domain: domainY}];
        pipeline = [
            {$match: matchArgs },
            {$group: {
                _id: {continent: "$continentName", countryCode: "$countryCode", countryName: "$countryName", domain: "$domain", industry: "$industry", occupation: "$occupation"},
                count: {$sum: 1 }
            }}
        ];
        // Imports Pipeline
        // pipeline = [
        //     { $match: matchArgs },
        //     {"$group": { _id: {lang:"$lang", domain: "$category", industry: "$industry", occupation: "$occupation"},
        //     "people": { "$addToSet": '$en_curid'}}},
        //     {"$unwind":"$people"},{"$group": { "_id": "$_id", "count": { "$sum":1} }}
        //     ];
        driver.mongo.db.collection("people").aggregate(
            pipeline,
            Meteor.bindEnvironment(
                function(err, result) {
                    _.each(result, function(e) {
                        // Generate a random disposable id for each aggregate
                        sub.added("scatterplot", Random.id(), {
                            continent: e._id.continent
                            , countryCode: e._id.countryCode
                            , countryName: e._id.countryName
                            , domain: e._id.domain
                            , industry: e._id.industry
                            , occupation: e._id.occupation
                            , count: e.count
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
});