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

# Minimize number of people collection queries
Template.person.helpers
  gender: -> if @gender is "Male" then "He" else "She"
  imagePath: -> imagePath = "/images/people/" + @en_curid + ".jpg"
  L_star: -> if @L_star then @L_star.toFixed(2)
  hpi: -> if @HPI then @HPI.toFixed(2) else "N/A"
  stdDevPageViews: -> (@StdDevPageViews / @TotalPageViews).toFixed(5)
  occupation: -> @occupation.capitalize()
  pageviews: -> if @TotalPageViews then numberWithCommas(@TotalPageViews)
  pageviews_e: -> if @PageViewsEnglish then numberWithCommas(@PageViewsEnglish)
  pageviews_ne: -> if @PageViewsNonEnglish then numberWithCommas(@PageViewsNonEnglish)
  birthday: -> (if (@birthyear < 0) then (@birthyear * -1) + " B.C." else @birthyear)
  peopleLeft: -> SimilarPeople.find(position: "left")
  peopleRight: -> SimilarPeople.find(position: "right")
  occupationRank: -> numberWithCommas(People.find(occupation: @occupation, HPI: {$gt: @HPI}, dataset: "OGC").count() + 1)
  birthyearRank: -> numberWithCommas(People.find(birthyear: @birthyear, HPI: {$gt: @HPI}, dataset: "OGC").count() + 1)
  countryRank: -> numberWithCommas(People.find(countryName: @countryName, HPI: {$gt: @HPI}, dataset: "OGC").count() + 1)
  occupationCount: -> numberWithCommas(People.find(occupation: @occupation, dataset: "OGC").count())  # TODO extract all counts into one publication
  birthyearCount: -> numberWithCommas(People.find(birthyear: @birthyear, dataset: "OGC").count())
  countryCount: -> numberWithCommas(People.find(countryName: @countryName, dataset: "OGC").count())
  rankingOccupation: -> (Session.get("rankingProperty") is "occupation")
  rankingBirthyear: -> (Session.get("rankingProperty") is "birthyear")
  rankingCountryName: -> (Session.get("rankingProperty") is "countryName")

Template.person_pill.helpers
  coloring: -> Session.get "rankingProperty"
  hidden: -> if @rank is -1 then true else false

# Desired search interaction model:
# On click off or esc, clear input
# On click of search icon, put into input
# On enter, either close drop down or submit
# Alternatively, click search button to submit
# If failure to submit, underline input with red
Template.person.events =
  "click #search-button": (d) ->
    val = $("input").val().trim()
    valid = People.find(name: val).count()
    if valid
      Router.go "people", 
        name: val
        dataset: ""
    else $("input").css(border: "1px solid red")

  "keydown #people-search": (d) ->
    if d.keyCode is 13
      Router.go "people", 
        name: val
        dataset: ""

  "click div.ranking-card": (d) ->
    srcE = $(if d.srcElement then d.srcElement else d.target)
    unless srcE.hasClass("ranking-card") then srcE = srcE.closest("div.ranking-card")

    rankingProperty = srcE.data "ranking-property"
    if rankingProperty
      console.log "CLICKED", rankingProperty
      Session.set("rankingProperty", rankingProperty)