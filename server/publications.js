Meteor.publish("countries", function() {
    return Countries.find()
});