Meteor.publish("map_pub", function(begin, end, L, category, categoryLevel) {
/*
The query will look something like this:
 db.people.aggregate([{"$match": {"numlangs": {"$gt": 25}, "birthyear": {"$gte": 0, "$lte":1950}, "domain": 'EXPLORATION'}},
 {"$group": {"_id": {"countryCode": "$countryCode3", "countryName": "$countryName"}, "count": {"$sum": 1 }}}])
 */
    var sub = this;
    var driver = MongoInternals.defaultRemoteCollectionDriver();

    // TODO modify this query to be more general

    var matchArgs = {
        numlangs: {$gt: L},
        birthyear: {$gte: begin, $lte:end}
    };

    if (category.toLowerCase() !== 'all' ) {
        matchArgs[categoryLevel] = category;
    };

    var pipeline = [];

    pipeline = [
        {$match: matchArgs },
        {$group: {
            _id: { countryCode: "$countryCode3", countryName: "$countryName"},
            count: {$sum: 1 }
        }}
    ];
    driver.mongo.db.collection("people").aggregate(
        pipeline,
        Meteor.bindEnvironment(
            function(err, result) {

                _.each(result, function(e) {
                    // Generate a random disposable id for each aggregate
                    sub.added("worldmap", Random.id(), {
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
});