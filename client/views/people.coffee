Template.people.dataReady = ->
  NProgress.inc()
  allpeopleSub.ready()

Template.people.helpers person: ->
  console.log People.findOne(name: Session.get("person"))
  People.findOne name: Session.get("person")

Template.person_name.settings = ->
  position: "bottom"
  limit: 5
  rules: [
    token: ""
    collection: People
    field: "name"
    template: Template.user_pill
  ]