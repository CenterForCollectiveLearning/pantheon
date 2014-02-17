numberWithCommas = (x) ->
  parts = x.toString().split(".")
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
  parts.join "."

Template.people.person = -> ClientPeople.findOne(name: Session.get("name"), dataset: "OGC")

Template.search.settings = ->
  position: "bottom"
  limit: 10
  rules: [
    token: ''
    collection: People
    field: "name"
    template: Template.search_result
  ]

Template.person_left.peopleLeft = -> SimilarPeople.find(position: "left")

Template.person_right.peopleRight = -> SimilarPeople.find(position: "right")

# Minimize number of people collection queries
Template.person_page.helpers
  gender: -> if @gender is "Male" then "He" else "She"
  L_star: -> if @L_star then @L_star.toFixed(2)
  hpi: -> if @HPI then @HPI.toFixed(2) else "N/A"
  stdDevPageViews: -> (@StdDevPageViews / @TotalPageViews).toFixed(5)
  occupation: -> @occupation.capitalize()
  pageviews: -> if @TotalPageViews then numberWithCommas(@TotalPageViews)
  pageviews_e: -> if @PageViewsEnglish then numberWithCommas(@PageViewsEnglish)
  pageviews_ne: -> if @PageViewsNonEnglish then numberWithCommas(@PageViewsNonEnglish)
  birthday: -> (if (@birthyear < 0) then (@birthyear * -1) + " B.C." else @birthyear)
  occupationRank: -> numberWithCommas(ClientPeople.find(occupation: @occupation, HPI: {$gt: @HPI}, dataset: "OGC").count() + 1)
  birthyearRank: -> numberWithCommas(ClientPeople.find(birthyear: @birthyear, HPI: {$gt: @HPI}, dataset: "OGC").count() + 1)
  countryRank: -> numberWithCommas(ClientPeople.find(countryName: @countryName, HPI: {$gt: @HPI}, dataset: "OGC").count() + 1)
  occupationCount: -> numberWithCommas(ClientPeople.find(occupation: @occupation, dataset: "OGC").count())  # TODO extract all counts into one publication
  birthyearCount: -> numberWithCommas(ClientPeople.find(birthyear: @birthyear, dataset: "OGC").count())
  countryCount: -> numberWithCommas(ClientPeople.find(countryName: @countryName, dataset: "OGC").count())
  rankingOccupation: -> Session.equals("rankingProperty", "occupation")
  rankingBirthyear: -> Session.equals("rankingProperty", "birthyear")
  rankingCountryName: -> Session.equals("rankingProperty","countryName")

Template.person_pill.helpers
  coloring: -> Session.get "rankingProperty"
  hidden: -> if @rank is -1 then true else false

Template.person_page.events =
  "click div.ranking-card": (d) ->
    srcE = $(if d.srcElement then d.srcElement else d.target)
    unless srcE.hasClass("ranking-card") then srcE = srcE.closest("div.ranking-card")

    rankingProperty = srcE.data "ranking-property"
    if rankingProperty
      Session.set("rankingProperty", rankingProperty)

  "click i#random-button": ->
    randomPersonName = People.findOne({dataset: "OGC"}, {skip: Math.round(Math.random() * People.find({dataset: "OGC"}).count())}).name
    Router.go "people", name: randomPersonName
