Handlebars.registerHelper "withif", (obj, options) ->
  if obj then options.fn(obj) else options.inverse(this)

# test these out in the console by setting the tutorialType!
# Session.set("tutorialType", "football")

renaissanceStory = [
  template: Template.renaissance_step1
  spot: ".wrapper"
  onLoad: ->
    Router.go "/treemap/country_exports/all/all/1300/1600/25/OGC"
,
  template: Template.renaissance_step2
  spot: "#viz"
,
  template: Template.renaissance_step3
  spot: "#cell_Writer rect"
,
  template: Template.renaissance_step4
  spot: "#cell_Painter rect"
,
  template: Template.renaissance_step5
  spot: ".wrapper"
  onLoad: ->
    Router.go "/treemap/domain_exports_to/all/all/1300/1600/25/OGC"
,
  template: Template.renaissance_step6
  spot: ".wrapper"
  onLoad: ->
    Router.go "/treemap/country_exports/IT/all/1300/1600/25/OGC"
,
  template: Template.renaissance_step7
  spot: "#wrapper"
  onLoad: ->
    Router.go "/scatterplot/country_vs_country/GB/FR/1300/1600/25/OGC"
,
  template: Template.renaissance_step8
  spot: "#viz"
,
  template: Template.renaissance_step9
  spot: ".wrapper"
  onLoad: ->
    Router.go "/treemap/country_exports/all/all/1300/1600/25/OGC"

]

explorationStory = [
  template: Template.explorers_step1
  spot:".page-middle span8"
  onLoad: ->
    Router.go "/treemap/country_exports/all/all/-3000/1950/25/OGC"
,
  template: Template.explorers_step2
  spot: "#cell_Explorer rect"
,
  template: Template.explorers_step3
  spot: "#viz"
  onLoad: ->
    Router.go "/treemap/country_exports/IS/all/-3000/1000/25/OGC"
,
  template: Template.explorers_step4
  spot: ".ranked_list"
,
  template: Template.explorers_step5
  spot: "#viz"
  onLoad: ->
    Router.go "/treemap/domain_exports_to/EXPLORATION/all/1000/1700/25/OGC"
,
  template: Template.explorers_step6
  spot: "#cell_ES rect, #cell_IT rect"
,
  template: Template.explorers_step7
  spot: "#cell_CN rect"
,
  template: Template.explorers_step8
  spot: ".wrapper"
  onLoad: ->
    Router.go "/treemap/domain_exports_to/EXPLORATION/all/1800/1900/25/OGC"
,
  template: Template.explorers_step9
  spot: "#cell_NO rect"
,
  template: Template.explorers_step10
  spot: ".wrapper"
  onLoad: ->
    Router.go "/treemap/domain_exports_to/EXPLORATION/all/1900/2000/25/OGC"
,
  template: Template.explorers_step11
  spot: ".wrapper"
,
  template: Template.explorers_step12
  spot: "#cell_US rect"
]

ogcStory = [
  template: Template.ogc_step1
,
  template: Template.ogc_step3
  spot: ".logo"
,
  template: Template.ogc_step4
  spot: ".wrapper"
  onLoad: ->
    Router.go "/treemap/country_exports/all/all/-3000/1950/25/OGC"
,
  template: Template.ogc_step5
  spot: ".page-left"
,
  template: Template.ogc_step6
  spot: ".wrapper"
  onLoad: ->
    Router.go "/treemap/domain_exports_to/all/all/-3000/1950/25/OGC"
,
  template: Template.ogc_step7
  spot: ".wrapper"
  onLoad: ->
    Router.go "/matrix/matrix_exports/all/all/-3000/1950/25/OGC"
,
  template: Template.ogc_step8
  spot: ".wrapper"
  onLoad: ->
    Router.go "/scatterplot/country_vs_country/US/RU/-3000/1950/25/OGC"
,
  template: Template.ogc_step9
  spot: ".wrapper"
  onLoad: ->
    Router.go "/map/map/all/all/-3000/1950/25/OGC"
,
  template: Template.ogc_step10
  onLoad: ->
    Router.go "/data"
,
  template: Template.ogc_step11
  spot: ".wrapper"
,
  template: Template.ogc_step12
  onLoad: ->
    Router.go "/rankings/countries/all/all/-3000/1950/25"
,
  template: Template.ogc_step13
  spot: "#ranking"
,
  template: Template.ogc_step14
  spot: "#wrapper"
  onLoad: ->
    Router.go "/rankings/people/all/all/-3000/1950/25"
,
  template: Template.ogc_step15
  onLoad: ->
    Router.go "/team"
]

renaissance =
  steps: renaissanceStory
  onFinish: -> Session.set("tutorialType", null)

exploration =
  steps: explorationStory
  onFinish: -> Session.set("tutorialType", null)

ogc =
  steps: ogcStory
  onFinish: -> Session.set("tutorialType", null)

Template.tutorial.tutorialOptions = ->
#  return null unless Session.get("dataReady")
  switch Session.get("tutorialType")
    when "renaissance" then renaissance
    when "moon" then exploration
    when "ogc" then ogc #next tutorials....
    else null

Template.tutorial.events =
  "click .quit": (d) ->
    Session.set("tutorialType", null)
  "click #goToAlfredo" : (d) ->
    Session.set("tutorialType", "renaissance")
  "click #goToNora" : (d) ->
    Session.set("tutorialType", "ogc")
  "click #goToDiana" : (d) ->
    Session.set("tutorialType", "moon")

