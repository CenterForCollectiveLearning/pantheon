numberWithCommas = (x) ->
  parts = x.toString().split(".")
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
  parts.join "."

Template.people.helpers 
  name: -> People.findOne name: Session.get("name")

Template.person.helpers
  gender: -> if @gender is "Male" then "He" else "She"
  L_star: -> @L_star.toFixed(2)
  hpi: -> @HPI.toFixed(2)
  stdDevPageViews: -> (@StdDevPageViews / @TotalPageViews).toFixed(2)
  occupation: -> @occupation.capitalize()
  pageviews: ->
    numberWithCommas(@TotalPageViews)
  birthday: -> (if (@birthyear < 0) then (@birthyear * -1) + " B.C." else @birthyear)
  occupationPeople: -> 
    Session.set "personID", @_id
    Session.set "personOccupation", @occupation
    OccupationPeople.find()
  birthyearPeople: -> 
    Session.set "personID", @_id
    Session.set "personBirthyear", @birthyear
    BirthyearPeople.find()
  countryPeople: -> 
    Session.set "personID", @_id
    Session.set "personCountry", @countryName
    CountryPeople.find()
  occupationPeopleCount: -> People.find(occupation: @occupation).count()  # TODO extract all counts into one publication
  birthyearPeopleCount: -> People.find(birthyear: @birthyear).count()
  countryPeopleCount: -> People.find(countryName: @countryName).count()

Template.ranking_person.helpers
  currentPerson: -> @_id.equals(People.findOne({"name": Session.get("name")})._id)