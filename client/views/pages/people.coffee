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


# TODO Map to search icon
Template.person_name.settings = ->
  position: "bottom"
  limit: 5
  rules: [
    token: ""  # No token (TODO if not provided, assume none)
    collection: People
    field: "name"
    template: Template.user_pill
  ]


Template.people_accordion.rendered = ->
  accordion = $(".people-accordion")
  accordion.accordion
    active: 0
    collapsible: false
    heightStyle: "content"
    fillSpace: false
  accordion.accordion "resize"


Template.people_accordion.helpers
  occupation: -> this.occupation.capitalize() + "s"
  time_period: -> this.birthyear
  # TODO Expose global date mapping, if notable time period or decade then state
  occupationPeople: -> 
    Session.set "personID", this._id
    Session.set "personOccupation", this.occupation
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