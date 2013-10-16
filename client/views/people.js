Template.people.dataReady = function() {
    NProgress.inc();
    return allpeopleSub.ready();
}

Template.people.helpers({
	person: function() {
		console.log(People.findOne({name:Session.get("person")}))
		return People.findOne({name:Session.get("person")});
	}
});

Template.person_name.settings = function() {
  return {
   position: "bottom"
   , limit: 5
   , rules: [
     {
       token: ''
       , collection: People
       , field: "name"
       , template: Template.user_pill
     }
   ]
  }
};