numberWithCommas = (x) ->
  parts = x.toString().split(".")
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
  parts.join "."

Template.people.personName = -> People.findOne(name: Session.get("name"), dataset: "OGC")

Template.search.settings = ->
  position: "bottom"
  limit: 5
  rules: [
    token: ''
    collection: People
    field: "name"
    template: Template.search_result
  ]

# TODO Design this smarter to receive all relevant data at once
Template.person.helpers
  name: -> @name
  gender: -> if @gender is "Male" then "He" else "She"
  imagePath: -> imagePath = "/images/people/" + @en_curid + ".jpg"
  L_star: -> if @L_star then @L_star.toFixed(2)
  hpi: -> if @HPI then @HPI.toFixed(2) else "N/A"
  stdDevPageViews: -> (@StdDevPageViews / @TotalPageViews).toFixed(2)
  occupation: -> @occupation.capitalize()
  pageviews: -> if @TotalPageViews then numberWithCommas(@TotalPageViews)
  birthday: -> (if (@birthyear < 0) then (@birthyear * -1) + " B.C." else @birthyear)
  peopleLeft: ->
    rankingProperty = Session.get("rankingProperty")
    if rankingProperty
      args = {HPI: {$gt: @HPI}}
      args[rankingProperty] = this[rankingProperty]
      People.find(args, {sort: {HPI: 1}, limit: 2}, dataset: "OGC").fetch().reverse()
  peopleRight: -> 
    rankingProperty = Session.get("rankingProperty")
    if rankingProperty
      args = {HPI: {$lt: @HPI}}
      args[rankingProperty] = this[rankingProperty]
      People.find(args, {sort: {HPI: -1}, limit: 2}, dataset: "OGC")
  occupationRank: -> 
    occupationRank = People.find(occupation: @occupation, HPI: {$gt: @HPI}, dataset: "OGC").count() + 1
    Session.set "occupationRank", occupationRank
    numberWithCommas(occupationRank)
  birthyearRank: -> 
    birthyearRank = People.find(birthyear: @birthyear, HPI: {$gt: @HPI}, dataset: "OGC").count() + 1
    Session.set "birthyearRank", birthyearRank
    numberWithCommas(birthyearRank)
  countryRank: -> 
    countryRank = People.find(countryName: @countryName, HPI: {$gt: @HPI}, dataset: "OGC").count() + 1
    Session.set "countryRank", countryRank
    numberWithCommas(countryRank)
  occupationCount: -> numberWithCommas(People.find(occupation: @occupation, dataset: "OGC").count())  # TODO extract all counts into one publication
  birthyearCount: -> numberWithCommas(People.find(birthyear: @birthyear, dataset: "OGC").count())
  countryCount: -> numberWithCommas(People.find(countryName: @countryName, dataset: "OGC").count())
  rankingOccupation: -> (Session.get("rankingProperty") is "occupation")
  rankingBirthyear: -> (Session.get("rankingProperty") is "birthyear")
  rankingCountryName: -> (Session.get("rankingProperty") is "countryName")

Template.person_pill.helpers
  coloring: -> Session.get "rankingProperty"
  currentRanking: ->
    rankingProperty = Session.get("rankingProperty")
    switch rankingProperty
      when "occupation" then Session.get("occupationRank")
      when "birthyear" then Session.get("birthyearRank")
      when "countryName" then Session.get("countryRank")
  getRank: -> 
    args = {HPI: {$gt: @HPI}}
    rankingProperty = Session.get("rankingProperty")
    args[rankingProperty] = this[rankingProperty]
    People.find(args).count() + 1

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
    srcE = $(if d.srcElement then d.srcElement else d.target)
    unless srcE.hasClass("ranking-card") then srcE = srcE.closest("div.ranking-card")
    console.log "CLICKED", srcE

    rankingProperty = srcE.data "ranking-property"
    if rankingProperty
      console.log "CLICKED", rankingProperty
      Session.set("rankingProperty", rankingProperty)