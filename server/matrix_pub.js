// Make sure this is indexed
Meteor.publish("matrix_pub", function(begin, end, L, gender) {
    var sub = this;

    var args = {
        numlangs: {$gt: L}
        , birthyear: {$gte: begin, $lte: end}
    }

    if (gender === 'male' || gender === 'female') {
        var query = gender.charAt(0).toUpperCase() + gender.slice(1);
        args.gender = query;
    }

    console.log(args);

    var project = {countryCode: 1, industry: 1, gender: 1};

    People.find(args, {fields: project}).forEach(function(person) {
        sub.added("matrix", Random.id(), person)
    });

    sub.ready();
});