Handlebars.registerHelper "withif", (obj, options) ->
  if obj then options.fn(obj) else options.inverse(this)

# test these out in the console by setting the tutorialType!
# Session.set("tutorialType", "football")

renaissanceStory = [
  template: Template.renaissance_step1
  onLoad: ->
    Router.go "/treemap/country_exports/all/all/1400/1600/25/OGC"
,
  template: Template.renaissance_step2
  spot: "#viz"
,
  template: Template.renaissance_step3
  spot: ".ranked_list"
,
  template: Template.renaissance_step4
  onLoad: ->
    Router.go "/treemap/domain_exports_to/PAINTER/all/1400/1600/25/OGC"
,
  template: Template.renaissance_step5
  spot: "#viz"
,
  template: Template.renaissance_step6
  spot: "#viz"
  onLoad: ->
    Router.go "/histogram/country_exports/IT/all/1400/1600/25/OGC"
]

footballStory = [
  template: Template.football_step1
  onLoad: ->
    Router.go "/treemap/domain_exports_to/AMERICAN%20FOOTBALL%20PLAYER/all/-3000/1950/25/OGC"
,
  template: Template.football_step2
  spot: "#viz, .ranked_list"
,
  template: Template.football_step3
  onLoad: ->
    Router.go "/map/map/SOCCER%20PLAYER/all/-3000/1950/25/OGC"
,
  template: Template.football_step4
  spot: "#viz"
]

renaissance =
  steps: renaissanceStory
  onFinish: -> Session.set("tutorialType", null)

football =
  steps: footballStory
  onFinish: -> Session.set("tutorialType", null)

tutorial3 = {}

Template.tutorial.tutorialOptions = ->
#  return null unless Session.get("dataReady")
  switch Session.get("tutorialType")
    when "renaissance" then renaissance
    when "football" then football
    when "tutorial3" then tutorial3 #next tutorials....
    else null