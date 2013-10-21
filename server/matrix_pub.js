// Make sure this is indexed
Meteor.publish("matrix_pub", function(begin, end, L, gender) {
    var sub = this;

    var args = {
        birthyear: {$gte: begin, $lte: end}
        , numlangs: {$gt: L}
    }

    if (gender === 'male' || gender === 'female') {
        var query = gender.charAt(0).toUpperCase() + gender.slice(1);
        args.gender = query;
    }

    People.find(args).forEach(function(person) {
        sub.added("matrix", person._id, person)
    });

    sub.ready();
});