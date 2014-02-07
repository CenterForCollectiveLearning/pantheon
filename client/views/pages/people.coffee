numberWithCommas = (x) ->
  parts = x.toString().split(".")
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
  parts.join "."

# Template.people.rendered = ->
  # TODO Move into a central location
  # Session.set("rankingProperty", "occupation")

Template.people.helpers
  person: -> People.findOne name: Session.get("name")

Template.search.settings = ->
  position: "bottom"
  limit: 5
  rules: [
    token: ''
    collection: People
    field: "name"
    template: Template.search_result
  ]

Template.person.helpers
  name: -> @name
  gender: -> if @gender is "Male" then "He" else "She"
  L_star: -> 
    console.log "HPI", @HPI
    if @L_star then @L_star.toFixed(2)
  hpi: -> 
    console.log "HPI", @HPI
    if @HPI then @HPI.toFixed(2) else "N/A"
  stdDevPageViews: -> (@StdDevPageViews / @TotalPageViews).toFixed(2)
  occupation: -> @occupation.capitalize()
  pageviews: -> if @TotalPageViews then numberWithCommas(@TotalPageViews)
  birthday: -> (if (@birthyear < 0) then (@birthyear * -1) + " B.C." else @birthyear)
  peopleLeft: ->
    args = {HPI: {$gt: @HPI}}
    rankingProperty = Session.get("rankingProperty")
    args[rankingProperty] = this[rankingProperty]
    People.find(args, {sort: {HPI: 1}, limit: 2})
  peopleRight: -> 
    args = {HPI: {$lt: @HPI}}
    rankingProperty = Session.get("rankingProperty")
    args[rankingProperty] = this[rankingProperty]
    People.find(args, {sort: {HPI: -1}, limit: 2})
  occupationRank: -> numberWithCommas(People.find(occupation: @occupation, HPI: {$gt: @HPI}).count() + 1)
  birthyearRank: -> numberWithCommas(People.find(birthyear: @birthyear, HPI: {$gt: @HPI}).count() + 1)
  countryRank: -> numberWithCommas(People.find(countryName: @countryName, HPI: {$gt: @HPI}).count() + 1)
  occupationCount: -> numberWithCommas(People.find(occupation: @occupation).count())  # TODO extract all counts into one publication
  birthyearCount: -> numberWithCommas(People.find(birthyear: @birthyear).count())
  countryCount: -> numberWithCommas(People.find(countryName: @countryName).count())

rankingPropertyColorMapping =
  occupation: "#4ede8a"
  birthyear: "#8ccdf4"
  countryName: "#f7b18b"

Template.person_pill.helpers
  coloring: -> Session.get "rankingProperty"

Template.person.events =
  "click #search-button": (d) ->
    val = $("input").val().trim()
    valid = People.find(name: val).count()
    if valid
      console.log "Valid person:", val
      Router.go "people", 
        name: val
        dataset: ""
    else $("input").css(border: "1px solid red")

  "click div.ranking-card": (d) ->
    srcE = (if d.srcElement then d.srcElement else d.target)
    rankingProperty = $(srcE).data "ranking-property"
    Session.set("rankingProperty", rankingProperty)

    $("div.ranking-card").removeClass("active")
    $(srcE).addClass("active")

  # "mouseenter div.ranking-card": (d) ->
  #   srcE = (if d.srcElement then d.srcElement else d.target)

  # "mouseleave div.ranking-card": (d) ->
  #   srcE = (if d.srcElement then d.srcElement else d.target)
  #   $(srcE).removeClass("active")

Template.ranking_person.helpers
  currentPerson: -> @_id.equals(People.findOne({"name": Session.get("name")})._id)