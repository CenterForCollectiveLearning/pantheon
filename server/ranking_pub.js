/*
 * Static query that pushes the countries ranking table
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
Meteor.publish("countries_ranking_pub", function(begin, end, category, categoryLevel) {
    var sub = this;
    var collectionName = "countries_ranking";

    var criteria = {
        birthyear: {$gte: begin, $lte:end}
    };

    if (category.toLowerCase() !== 'all' ) {
        criteria[categoryLevel] = category;
    };

    var country = {};

    var data = People.find(criteria);
    var countries =_.groupBy(data.fetch(), "countryCode");
    var finaldata = [];
    for (var cc in countries){
        country = {};
        country["countryCode"] = cc;
        country["countryName"] = countries[cc][0].countryName;
        country["continentName"] = countries[cc][0].continentName;
        country["numppl"] = countries[cc].length;
        var females = _.countBy(countries[cc], function(p) {
            return p.gender === 'Female' ? 'Female': 'Male';
        }).Female;
        country["numwomen"] = females ? females : 0;
        country["i50"] = countries[cc][0]['i50'];
        country["Hindex"] = countries[cc][0]['Hindex'];
        country["diversity"] = Object.keys(_.groupBy(countries[cc], "occupation")).length;
        country["percentwomen"] = (country["numwomen"]/country["numppl"]*100.0).toFixed(2);
        finaldata.push(country);
    };


    finaldata.forEach(function(person){
        sub.added(collectionName, Random.id(), person);
    });

    sub.ready();
    return;
});

Meteor.publish("domains_ranking_pub", function(begin, end, country, category, categoryLevel) {
    var sub = this;
    var collectionName = "domains_ranking";

    var criteria = {
        birthyear: {$gte: begin, $lte:end}
    };

    if (country !== 'all' ) {
        criteria.countryCode = country;
    }

    if (category.toLowerCase() !== 'all' ) {
        criteria[categoryLevel] = category;
    };

    var domain = {};

    var data = People.find(criteria);
    var domains =_.groupBy(data.fetch(), "occupation");
    var finaldata = [];
    for (var d in domains){
        domain = {};
        domain["occupation"] = d;
        domain["industry"] = domains[d][0].industry;
        domain["domain"] = domains[d][0].domain;
        domain["ubiquity"] = Object.keys(_.groupBy(domains[d], "countryCode")).length;
        domain["numppl"] = domains[d].length;
        var females = _.countBy(domains[d], function(p) {
            return p.gender === 'Female' ? 'Female': 'Male';
        }).Female;
        domain["numwomen"] = females ? females : 0;
        domain["percentwomen"] = (domain["numwomen"]/domain["numppl"]*100.0).toFixed(2);
        finaldata.push(domain);
    };


    finaldata.forEach(function(person){
        sub.added(collectionName, Random.id(), person);
    });

    sub.ready();
    return;
});


