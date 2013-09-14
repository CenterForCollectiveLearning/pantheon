Meteor.publish("countries", function() {
    return Countries.find();
});

Meteor.publish("peopletop10", function(begin, end, L, country){
    var sub = this;
    var top10peopleHandle;
    var collectionName = "top10people";

    var args = {
        birthyear : {$gt:begin, $lte:end}
    };
    if (country !== 'all' ) {
        args.countryCode = country;
    }

    top10peopleHandle = People.find(args, {limit:10}).observe({
        added: function(person) {
            sub.added(collectionName, person._id, person);
        },
        removed: function(person) {
            sub.removed(collectionName, person._id);
        }
    });

    sub.ready();

    // make sure we clean everything up
    sub.onStop(function() {
        top10peopleHandle.stop();
    });

    return; //TODO: add sort by numlangs
});

Meteor.publish("people", function(begin, end, L, country, occ){
    var args = {
        birthyear : {$gt:begin, $lte:end}
    };
    if (country !== 'all' ) {
        args.countryCode = country;
    }
    if (occ !== 'all') {
        args.occupation = occ;
    }

   return People.find(args); //TODO: add sort by numlangs
});

// TODO double check this indexing
People._ensureIndex({ birthyear: 1, countryCode: 1,  occupation: 1} )

Meteor.publish("domain", function(begin, end, L, country) {



});