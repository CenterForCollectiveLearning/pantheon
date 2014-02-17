# Global variables for treemap and scatterplot colors
@boilingOrange = "#F29A2E"
@chiliRed = "#C14925"
@sapGreen = "#587507"
@brickBrown = "#72291D"
@seaGreen = "#46AF69"
@salmon = "#EB7151"
@manganeseBlue = "#129B97"
@magenta = "#822B4C"

@color_domains = d3.scale.ordinal()
  .domain(["INSTITUTIONS", "ARTS", "HUMANITIES", "BUSINESS & LAW", "EXPLORATION", "PUBLIC FIGURE", "SCIENCE & TECHNOLOGY", "SPORTS", "Art", "Lit", "Music", "Phil", "Science"])
  .range([salmon, boilingOrange, brickBrown, sapGreen, chiliRed, seaGreen, manganeseBlue, magenta, boilingOrange, brickBrown, salmon, chiliRed, magenta, manganeseBlue])

@color_countries = d3.scale.ordinal()
  .domain(["Africa", "Asia", "Europe", "North America", "South America", "Oceania", "Unknown"])
  .range([manganeseBlue, boilingOrange, salmon, sapGreen, chiliRed, seaGreen, brickBrown, magenta])

# @color_languages = d3.scale.ordinal()
#   .domain(["Afro-Asiatic", "Altaic", "Austro-Asiatic", "Austronesian", "Basque", "Caucasian", "Creoles and pidgins", "Dravidian", "Eskimo-Aleut", "Indo-European", "Niger-Kordofanian", "North American Indian", "Sino-Tibetan", "South American Indian", "Tai", "Uralic"])
#   .range(["#E0BA9B", "#D95B43", "#43c1d9", "#C02942", "#546c97", "#d278c2", "#53a9f1", "#79BD9A", "#A69E80", "#ECD078", "#D28574", "#E7EDEA", "#CEECEF", "#912D1D", "#DE7838", "#59AB6D"])

Template.visualization.rendered = ->
  if Session.equals("showMobileRankingMenu", true)
    $(".fa-search-plus").hide()
    $(".fa-search-minus").show()
    $(".parameters").show()

# Re-render visualization template on window resize
Template.visualization.resize = -> if Session.get "resize" then return

# Render SVGs and ranked list based on current vizMode
Template.visualization.render_template = ->
  type = Session.get "vizType"
  switch type
    when "treemap" then new Handlebars.SafeString(Template.treemap(this))
    when "matrix" then new Handlebars.SafeString(Template.matrix(this))
    when "scatterplot" then new Handlebars.SafeString(Template.scatterplot(this))
    when "map" then new Handlebars.SafeString(Template.map(this))
    when "histogram" then new Handlebars.SafeString(Template.histogram(this))
    when "stacked" then new Handlebars.SafeString(Template.stacked(this))

Template.time_slider.rendered = ->
  # Not sure why this works, but it overcomes the re-styling issue
  $("div#from > select, div#to > select").selectToUISlider
    labels: 20
    tooltip: false

Template.accordion.rendered = ->
  mapping = 
    treemap: 0
    matrix: 1
    scatterplot: 2
    map: 3
    histogram: 4
    stacked: 5

  accordion = $(".accordion")
  accordion.accordion
    active: mapping[Session.get("vizType")]
    collapsible: false
    heightStyle: "content"
    fillSpace: false

Template.accordion.country_treemap_active = -> if Session.equals("vizMode", "country_exports") then "active" else ""
Template.accordion.domain_treemap_active = -> if Session.equals("vizMode", "domain_exports_to") then "active" else ""
Template.accordion.matrix_active = -> if Session.equals("vizMode", "matrix_exports") then "active" else ""
Template.accordion.cvc_active = -> if Session.equals("vizMode", "country_vs_country") then "active" else ""
Template.accordion.dvd_active = -> if Session.equals("vizMode", "domain_vs_domain") then "active" else ""
Template.accordion.map_active = -> if Session.equals("vizMode", "map") then "active" else ""
Template.accordion.from = -> Session.get("from")
Template.accordion.to = -> Session.get("to")
Template.accordion.index = -> Session.get("langs")
Template.accordion.dataset = -> if Session.equals("dataset", "murray") then "murray" else "pantheon"
Template.accordion.randomCountry = -> if Session.equals("dataset", "murray") then getRandomFromArray(murrayCountries) else getRandomFromArray(countriesOverTenPeople)
Template.accordion.randomDomain = -> if Session.equals("dataset", "murray") then getRandomFromArray(_.values(mpdomains)) else getRandomFromArray(_.keys(mpdomains))
Template.accordion.randomCountryX = -> if Session.equals("dataset", "murray") then getRandomFromArray(murrayCountries.slice(0, murrayCountries.length/2)) else getRandomFromArray(countriesOverTenPeople.slice(0,countriesOverTenPeople.length/2))
Template.accordion.randomDomainX = -> if Session.equals("dataset", "murray") then getRandomFromArray((_.values(mpdomains)).slice(0, (_.values(mpdomains)).length/2)) else getRandomFromArray((_.keys(mpdomains)).slice(0, (_.keys(mpdomains)).length/2))
Template.accordion.randomCountryY = -> if Session.equals("dataset", "murray") then getRandomFromArray(murrayCountries.slice(murrayCountries.length/2)) else getRandomFromArray(countriesOverTenPeople.slice(countriesOverTenPeople.length/2))
Template.accordion.randomDomainY = -> if Session.equals("dataset", "murray") then getRandomFromArray((_.values(mpdomains)).slice((_.values(mpdomains)).length/2)) else getRandomFromArray((_.keys(mpdomains)).slice((_.keys(mpdomains)).length/2))

# Template.accordion.events = #rewrite this such that links are rendered instead of Router.go
#   "click li a": (d) ->
#     srcE = (if d.srcElement then d.srcElement else d.target)
#     vizType = $(srcE).data "viz-type"
#     vizMode = $(srcE).data "viz-mode"
#     dataset = Session.get("dataset")
#     # Parameters depend on vizMode (e.g countries -> languages for exports)
#     [paramOne, paramTwo] = IOMapping[vizMode]["in"]
#     unless paramOne is "all"
#       paramOne = Session.get(paramOne)
#     unless paramTwo is "all"
#       paramTwo = Session.get(paramTwo)
#     if vizMode in ["domain_exports_to","map"] and dataset is "OGC"# to randomize the domain when you click on domains
#       paramOne = getRandomFromArray(_.keys(mpdomains))
#     if vizMode in ["domain_exports_to","map"] and dataset is "murray"# to randomize the domain when you click on domains
#       paramOne = getRandomFromArray(_.values(mpdomains))
#     if vizMode is "country_exports" and dataset is "OGC"# to randomize the domain when you click on domains
#       paramOne = getRandomFromArray(countriesOverTenPeople)
#     if vizMode is "country_exports" and dataset is "murray"# to randomize the domain when you click on domains
#       paramOne = getRandomFromArray(murrayCountries)
#     if vizMode is "country_vs_country" and dataset is "OGC"
#       paramOne = getRandomFromArray(countriesOverTenPeople)
#       paramTwo = getRandomFromArray(countriesOverTenPeople)
#       while paramOne is paramTwo
#         paramTwo = getRandomFromArray(countriesOverTenPeople)
#     if vizMode is "country_vs_country" and dataset is "murray"
#       paramOne = getRandomFromArray(murrayCountries)
#       paramTwo = getRandomFromArray(murrayCountries)
#       while paramOne is paramTwo
#         paramTwo = getRandomFromArray(murrayCountries)
#     if vizMode is "domain_vs_domain" and dataset is "OGC"
#       paramOne = getRandomFromArray(_.keys(mpdomains))
#       paramTwo = getRandomFromArray(_.keys(mpdomains))
#       while paramOne is paramTwo
#         paramTwo = getRandomFromArray(_.keys(mpdomains))
#     if vizMode is "domain_vs_domain" and dataset is "murray"
#       paramOne = getRandomFromArray(_.values(mpdomains))
#       paramTwo = getRandomFromArray(_.values(mpdomains))
#       while paramOne is paramTwo
#         paramTwo = getRandomFromArray(_.values(mpdomains))

#     # Use session variables as parameters for a viz type change
#     Router.go "explore",
#       vizType: vizType
#       vizMode: vizMode
#       paramOne: paramOne
#       paramTwo: paramTwo
#       from: Session.get("from")
#       to: Session.get("to")
#       langs: Session.get("langs")
#       gender: Session.get("gender")
#       dataset: if dataset is "murray" then dataset else if dataset is "OGC" then "pantheon"

# Global helper for data ready
Handlebars.registerHelper "dataReady", ->
  Session.get "dataReady"

Handlebars.registerHelper "initialDataReady", ->
  Session.get "initialDataReady"

Handlebars.registerHelper "tooltipDataReady", ->
  Session.get "tooltipDataReady"

# Create a global helper
# Use this from multiple templates
Handlebars.registerHelper "person_lookup", ->
  console.log @_id, ClientPeople.findOne()
  ClientPeople.findOne @_id

Template.ranked_list.top10 = ->
  if Session.get("indexType") is "HPI" then order = {HPI:-1}
  else order = {numlangs:-1}
  PeopleTopN.find({}, {sort:order})

Template.ranked_list.pantheon = ->
  Session.equals("dataset", "OGC") and not Session.equals("vizType", "scatterplot") and not (PeopleTopN.find().count() is 0)

Template.ranked_list.empty = ->
  PeopleTopN.find().count() is 0

Template.ranked_person.showPeopleLink = -> Session.equals("dataset", "OGC")

Template.ranked_person.birthday = ->
  birthday = (if (@birthyear < 0) then (@birthyear * -1) + " B.C." else @birthyear)
  birthday

Template.ranked_person.index = ->
  if Session.get("indexType") is "HPI" and Session.get("dataset") is "OGC" then @HPI?.toFixed(2) else @numlangs

Template.mobile_tooltip_ranking.full_ranking_link = ->
  "/rankings/people/" + Session.get("tooltipCountryCode") + "/" + Session.get("tooltipCategory") + "/" + Session.get("from") + "/" + Session.get("to") + "/" + Session.get("langs")

Template.ranked_list.full_ranking_link = ->
  "/rankings/people/" + Session.get("country") + "/" + Session.get("category") + "/" + Session.get("from") + "/" + Session.get("to") + "/" + Session.get("langs")

Template.date_header.helpers
  from: ->
    from = Session.get("from")
    return "1 A.D."  if from is "1"
    (if (from < 0) then (from * -1) + " B.C." else from)

  to: ->
    to = Session.get("to")
    return "1 A.D."  if to is "1"
    (if (to < 0) then (to * -1) + " B.C." else to)

Template.question.events =
  "click .fa-search-plus": (d) ->
      $(".fa-search-plus").hide()
      $(".fa-search-minus").show()
      $("#explore-parameters").show("fast")
      Session.set("showMobileRankingMenu", true)
  "click .fa-search-minus": (d) ->
      $(".fa-search-minus").hide()
      $(".fa-search-plus").show()
      $("#explore-parameters").hide("fast")
      Session.set("showMobileRankingMenu", false)

# Template.feedback.mailto = ->
#   url = "mailto:?subject=[Feedback]&amp;to=pantheon@media.mit.edu&amp;body=%0D%0A%0D%0A%0D%0A%0D%0A%0D%0A ################################%0D%0A Debug Log – Do not remove%0D%0A ################################%0D%0A%0D%0A URL:" + encodeURIComponent(location.href) + "%0D%0A Browser: " + navigator.userAgent + "%0D%0A Mobile: " + Session.get("mobile") + "%0D%0A%0D%0A################################"
#   url


Template.feedback.events = 
    "click a.contactus": ->
      question = $("#question").text()
      width  = 575
      height = 400
      left   = ($(window).width()  - width)  / 2
      top    = ($(window).height() - height) / 2  # encodeURIComponent(location.href)
      url    = "mailto:?subject=[Feedback]&amp;to=pantheon@media.mit.edu&amp;body=%0D%0A%0D%0A%0D%0A%0D%0A%0D%0A ################################%0D%0A Debug Log – Do not remove%0D%0A ################################%0D%0A%0D%0A URL:" + encodeURIComponent(location.href) + "%0D%0A Browser: " + navigator.userAgent + "%0D%0A Mobile: " + Session.get("mobile") + "%0D%0A%0D%0A################################"
      opts   = 'status=1' +
             ',width='  + width  +
             ',height=' + height +
             ',top='    + top    +
             ',left='   + left

      win = window.open(url, 'email', opts)
      setTimeout (-> #close the window because email client opens message window
        win.close()
        return
      ), 1000
      false

# Generate question given viz type
Template.question.question = -> 
  dataset = Session.get("dataset")
  try
    country = if Session.get("country") is "all" then "the world" else Countries.findOne({countryCode: Session.get("country"), dataset: dataset}).countryName
  try # separate out the countryX and countryY try becaused if country is not in the same dataset it kicks out the rest of the assignments
    countryX = if Session.get("countryX") is "all" then "the world" else Countries.findOne({countryCode: Session.get("countryX"), dataset: dataset}).countryName
    countryY = if Session.get("countryY") is "all" then "the world" else Countries.findOne({countryCode: Session.get("countryY"), dataset: dataset}).countryName
  vars = 
    country: country
    countryX: countryX
    countryY: countryY
    category: if Session.get("category") is "all" then "all domains" else Session.get("category").capitalize()
    categoryX: if Session.get("categoryX") is "all" then "all domains" else Session.get("categoryX").capitalize()
    categoryY: if Session.get("categoryY") is "all" then "all domains" else Session.get("categoryY").capitalize()
    gender_var: Session.get("gender")
    categoryLevel: Session.get("categoryLevel")
  mode = Session.get("vizMode")
  getQuestion(mode, vars)

@boldify = (str) -> "<b>" + str + "</b>"
@getQuestion = (mode, vars) ->
  dataset = Session.get("dataset")
  # If mode requires a category, switch based on categoryLevel because occupations are singular
  if mode in ["domain_exports_to", "map", "domain_vs_domain"]
    # Default to empty
    category_prefix = ""
    unless vars.category is "all domains"
      switch vars.categoryLevel
        when "domain", "industry" then category_prefix = " individuals in "
        when "occupation"
          if vars.category is "Martial Arts" then vars.category = "Martial Artists" 
          if dataset is "murray" then category_prefix = " individuals in "
          else if dataset is "OGC" then vars.category = vars.category + "s"
    else category_prefix = " individuals in "

  # If mode requires gender, then change subject
  if mode in ["matrix_exports"]
      switch vars.gender_var
        when "both" then vars.gender_var = "men and women"
        when "male" then vars.gender_var = "men"
        when "female" then vars.gender_var = "women"

  # Actually construct the question
  switch mode
    when "country_exports" then return new Handlebars.SafeString("Who are the globally known people born in " + boldify(vars.country) + "?")
    when "domain_exports_to", "map" 
      return new Handlebars.SafeString("Where were globally known " + category_prefix + boldify(vars.category) + " born?")
    when "matrix_exports"
      if vars.gender_var is "ratio" then return new Handlebars.SafeString("What's the " + boldify("female to male") + " ratio for each country and cultural domain?")
      else return new Handlebars.SafeString("How many globally known " + boldify(vars.gender_var) + " are associated with each country and cultural domain?")
    when "country_vs_country" then return new Handlebars.SafeString("How do " + boldify(vars.countryX) + " and " + boldify(vars.countryY) + " compare in terms of number of globally known people?")
    when "domain_vs_domain" then return new Handlebars.SafeString("What countries have produced globally known people in " + boldify(vars.categoryX) + " and " + boldify(vars.categoryY) + "?")

#
# TOOLTIPS 
# 
Template.tooltip.helpers
  tooltipShown: -> (Session.get("showTooltip") and not Session.get("clicktooltip"))

  position: -> Session.get "tooltipPosition"

  top5: -> # Total count is also passed
    if Session.get("indexType") is "HPI" then order = {HPI:-1}
    else order = {numlangs:-1}
    Tooltips.find({_id:{$not: "count"}}, {sort:order})

  count: ->
    doc = Tooltips.findOne(_id: "count")
    (if (typeof doc isnt "undefined") then doc.count else 0)

  suffix: ->
    doc = Tooltips.findOne(_id: "count")
    (if (typeof doc isnt "undefined" and doc.count > 1) then "individuals" else "individual")

  more: ->
    doc = Tooltips.findOne(_id: "count")
    (if (typeof doc isnt "undefined") then doc.count > 5 else false)

  extras: ->
    doc = Tooltips.findOne(_id: "count")
    (if (typeof doc isnt "undefined") then doc.count - 5 else 0)

#
# MOBILE TOOLTIPS (rankings tables)
# 
Template.mobile_tooltip_ranking.helpers
  tooltipShown: -> (Session.get("showTooltip") and not Session.get("clicktooltip"))

  position: -> Session.get "tooltipPosition"

  top5: -> # Total count is also passed
    if Session.get("indexType") is "HPI" then order = {HPI:-1}
    else order = {numlangs:-1}
    Tooltips.find({_id:{$not: "count"}}, {sort:order})

  count: ->
    doc = Tooltips.findOne(_id: "count")
    (if (typeof doc isnt "undefined") then doc.count else 0)

  suffix: ->
    doc = Tooltips.findOne(_id: "count")
    (if (typeof doc isnt "undefined" and doc.count > 1) then "individuals" else "individual")

  more: ->
    doc = Tooltips.findOne(_id: "count")
    (if (typeof doc isnt "undefined") then doc.count > 5 else false)

  extras: ->
    doc = Tooltips.findOne(_id: "count")
    (if (typeof doc isnt "undefined") then doc.count - 5 else 0)


Template.tt_person.birthday = -> (if (@birthyear < 0) then (@birthyear * -1) + " B.C." else @birthyear)

Template.tt_person.index = ->
  if Session.get("indexType") is "HPI" and Session.get("dataset") is "OGC" then @HPI.toFixed(2) else @numlangs

Template.clicktooltip.helpers
  showclicktooltip: -> Session.get "clicktooltip"
  categoryName : -> Session.get("bigtooltipCategory").capitalize()
  category : -> Session.get("bigtooltipCategory")
  from : -> Session.get("from")
  to : -> Session.get("to")
  L : -> Session.get("langs")
  dataset : -> Session.get("dataset")
  count: ->
    doc = Tooltips.findOne(_id: "count")
    (if (typeof doc isnt "undefined") then doc.count else 0)

Template.clicktooltip.render_links = ->
  vizType = Session.get("vizType")
  vizMode = Session.get("vizMode")
  switch vizType
    when "treemap", "scatterplot"
      if vizMode in ["country_exports", "country_vs_country"]
        return new Handlebars.SafeString(Template.tt_treemap_country_exports(this))
      else if vizMode in ["domain_exports_to", "domain_vs_domain"]
        return new Handlebars.SafeString(Template.tt_treemap_domain_exports_to(this))
    when "matrix","map"
      return new Handlebars.SafeString(Template.tt_global_exports(this))
    when "histogram"
      if vizMode is "country_exports"
        return new Handlebars.SafeString(Template.tt_histogram_country_exports(this))
      else if vizMode is "domain_exports_to"
        return new Handlebars.SafeString(Template.tt_histogram_domain_exports_to(this))

Template.domain_exporter_question.question = -> 
  category = Session.get("bigtooltipCategory")
  categoryLevel = getCategoryLevel(category)
  if category is "all" then category = "all domains" else category = category.capitalize()
  getQuestion("domain_exports_to", {category: category, categoryLevel: categoryLevel})

Template.country_exports_question.question = -> 
  countryCode = Session.get("tooltipCountryCode")
  dataset = Session.get("dataset")
  vizMode = Session.get("vizMode")
  if vizMode is "map" and dataset is "murray"
    country = (Countries.findOne({countryCode3: countryCode}).countryName).capitalize()
  else 
    country = (Countries.findOne({countryCode: countryCode, dataset: dataset}).countryName).capitalize() 
  getQuestion("country_exports", {country: country})

Template.country_advantage_question.countryName = ->
  countryCode = Session.get("tooltipCountryCode")
  return (Countries.findOne({$or: [{countryCode: countryCode}, {countryCode3: countryCode}]}).countryName).capitalize()

Template.domain_advantage_question.categoryName = ->
  Session.get("bigtooltipCategory").capitalize()

Template.treemap_domain_exports_to.helpers
  category : -> Session.get("bigtooltipCategory")
  from : -> Session.get("from")
  to : -> Session.get("to")
  L : -> Session.get("langs")
  dataset : -> Session.get("dataset")

Template.treemap_country_exports.helpers
  country : -> 
    dataset = Session.get("dataset")
    vizMode = Session.get("vizMode")
    countryCode = Session.get("bigtooltipCountryCode")
    if vizMode is "map" and dataset is "murray"
      return Countries.findOne({countryCode3: countryCode}).countryCode
    else
      return countryCode
  from : -> Session.get("from")
  to : -> Session.get("to")
  L : -> Session.get("langs")
  dataset : -> Session.get("dataset")

Template.map_global_exports.helpers
  category : -> Session.get("bigtooltipCategory")
  from : -> Session.get("from")
  to : -> Session.get("to")
  L : -> Session.get("langs")
  dataset : -> Session.get("dataset")

Template.histogram_domain_exports_to.helpers
  category : -> Session.get("bigtooltipCategory")
  from : -> Session.get("from")
  to : -> Session.get("to")
  L : -> Session.get("langs")
  dataset : -> Session.get("dataset")

Template.histogram_country_exports.helpers
  country : -> Session.get("bigtooltipCountryCode")
  from : -> Session.get("from")
  to : -> Session.get("to")
  L : -> Session.get("langs")
  dataset : -> Session.get("dataset")

Template.mobile_tooltip_ranking.pantheon = ->
  Session.equals("dataset", "OGC") and not Session.equals("vizType", "scatterplot") and not (PeopleTopN.find().count() is 0)

Template.clicktooltip.pantheon = ->
  Session.equals("dataset", "OGC") and not Session.equals("vizType", "scatterplot") and not (PeopleTopN.find().count() is 0)

Template.clicktooltip.full_ranking_link = ->
    "/rankings/people/" + Session.get("bigtooltipCountryCode") + "/" + Session.get("bigtooltipCategory") + "/" + Session.get("from") + "/" + Session.get("to") + "/" + Session.get("langs")


Template.clicktooltip.events =
  # TODO Ensure this works for tap
  "click .d3plus_tooltip_close,.d3plus_tooltip_curtain": (d) ->
    Session.set "clicktooltip", false
  "click .closeclicktooltip": (d) ->
    Session.set "clicktooltip", false
