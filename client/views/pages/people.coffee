numberWithCommas = (x) ->
  parts = x.toString().split(".")
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
  parts.join "."

Template.people.rendered = ->
  # TODO Move into a central location
  Session.set("rankingProperty", "occupation")

Template.people.helpers
  person: -> People.findOne name: Session.get("name")

Template.person.helpers
  name: -> @name
  gender: -> if @gender is "Male" then "He" else "She"
  L_star: -> @L_star.toFixed(2)
  hpi: -> 
    console.log "HPI", @HPI
    @HPI.toFixed(2)
  stdDevPageViews: -> (@StdDevPageViews / @TotalPageViews).toFixed(2)
  occupation: -> @occupation.capitalize()
  pageviews: ->
    numberWithCommas(@TotalPageViews)
  birthday: -> (if (@birthyear < 0) then (@birthyear * -1) + " B.C." else @birthyear)
  occupationPeople: -> 
    Session.set "personID", @_id
    Session.set "personOccupation", @occupation
    console.log "SIMILAR OCCUPATION", OccupationPeople.find().fetch()
    OccupationPeople.find()
  birthyearPeople: -> 
    Session.set "personID", @_id
    Session.set "personBirthyear", @birthyear
    BirthyearPeople.find()
  countryPeople: -> 
    Session.set "personID", @_id
    Session.set "personCountry", @countryName
    CountryPeople.find()
  occupationPeopleCount: -> numberWithCommas(People.find(occupation: @occupation).count())  # TODO extract all counts into one publication
  birthyearPeopleCount: -> numberWithCommas(People.find(birthyear: @birthyear).count())
  countryPeopleCount: -> numberWithCommas(People.find(countryName: @countryName).count())

Template.person.events = 
  "mouseenter div.card": (d) ->
    srcE = (if d.srcElement then d.srcElement else d.target)
    rankingProperty = $(srcE).data "ranking-property"
    Session.set("rankingProperty", rankingProperty)
    console.log "rankingProperty", Session.get("rankingProperty")

Template.ranking_person.helpers
  currentPerson: -> @_id.equals(People.findOne({"name": Session.get("name")})._id)