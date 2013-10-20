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
 Publish the top N people for the current query
 This is a static query since the query doesn't ever change for some given parameters
 Push the ids here as well since people will be in the client side
 */
Meteor.publish("peopletopN", function(begin, end, L, country, domain, N) {
    var sub = this;
    var collectionName = "topNpeople";

    var criteria = getCountryExportArgs(begin, end, L, country);

    var projection = {};

    if(N !== 'all'){
        projection.limit = N;
    }

    if (domain.toLowerCase() !== 'all' ) {
        criteria.$or = [{domain:domain.substring(1)}, {industry:domain.substring(1)}, {occupation:domain.substring(1)}];
    };

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
Also a static query
does not send over anything other than the people ids,
because the whole set of people already exists client side
*/
Meteor.publish("top5occupation", function(begin, end, L, country, industry, gender) {
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

/*
 * Static query that pushes the countries ranking table
 * This needs to run a native mongo query due to aggregates being not supported directly yet
 *
 * this is the equivalent SQL query:
 * SELECT a.*, b.numwomen, (b.numwomen*1.0/numppl)*100.0 as percent_female
 * FROM
     * (select countryName, countryCode,  count(distinct en_curid) as numppl, count(distinct occupation) numoccs, i50, Hindex
     * from culture3
     * where occupation == "ASTRONAUT"
     * group by countryCode limit 30)
 * AS a
 * left join
 * (select countryCode, count(distinct en_curid) as numwomen
 * from culture3
 * where gender == 'Female' and occupation == "ASTRONAUT"
 * group by countryCode)
 * as b
 * on a.countryCode == b.countryCode;
 *
 */
Meteor.publish("countries_ranking_pub", function(begin, end, domain) {
    var sub = this;
    var collectionName = "countries_ranking";

    var criteria = {
        birthyear: {$gte: begin, $lte:end}
    };

    if (domain.toLowerCase() !== 'all' ) {
        domain = domain.substring(1);
        // TODO don't include category in this match for pages that are automatically 'all'
        criteria.$or = [{domain:domain}, {industry:domain}, {occupation:domain}];
    };

    var data = People.find(criteria);

    data.forEach(function(person){
        sub.added(collectionName, Random.id(), person);
    });

    sub.ready();
    return;
});