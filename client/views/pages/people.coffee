Template.people.helpers 
  name: -> 
  	name = People.findOne name: Session.get("name")

Template.person.helpers
  gender: ->
  	if this.gender is "Male" then "He" else "She"
  occupation: -> this.occupation.capitalize()


Template.person.events
  "mouseenter .country-name": -> $(".people-accordion").accordion('activate', 2)
  "mouseenter .occupation": -> $(".people-accordion").accordion('activate', 0)
  "mouseenter .birthyear": -> $(".people-accordion").accordion('activate', 1)


Template.person_name.settings = ->
  position: "bottom"
  limit: 5
  rules: [
    token: ""  # No token (TODO if not provided, assume none)
    collection: People
    field: "name"
    template: Template.user_pill
  ]

Template.people_accordion.events = 
  "mouseenter li.person": (d) ->
    srcE = (if d.srcElement then d.srcElement else d.target)
    $(srcE).find("div.top-info, div.bottom-info").addClass("hovered")

  "mouseleave li.person": (d) ->
    srcE = (if d.srcElement then d.srcElement else d.target)
    $(srcE).find("div.top-info, div.bottom-info").removeClass("hovered")

Template.people_accordion.rendered = ->
  accordion = $(".people-accordion")
  accordion.accordion
    active: 0
    collapsible: false
    heightStyle: "content"
    fillSpace: false

Template.ranking_person.helpers
  currentPerson: -> this._id.equals(People.findOne({"name": Session.get("name")})._id)

Template.people_accordion.helpers
  occupation: -> this.occupation.capitalize() + "s"
  time_period: -> this.birthyear
  # TODO Expose global date mapping, if notable time period or decade then state
  personImports: -> 
    Session.set "personID", this._id
    Imports.find()
  occupationPeople: -> 
    Session.set "personID", this._id
    Session.set "personOccupation", this.occupation
    console.log "occupation", OccupationPeople.find().count()
    OccupationPeople.find()
  birthyearPeople: -> 
    Session.set "personID", this._id
    Session.set "personBirthyear", this.birthyear
    BirthyearPeople.find()
    # People.find({birthyear: this.birthyear}, {limit: 5})
  countryPeople: -> 
    Session.set "personID", this._id
    Session.set "personCountry", this.countryName
    CountryPeople.find()