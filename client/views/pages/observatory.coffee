# Helper methods for observatory page
Template.sharing_options.rendered = ->
  
  # Google Plus
  po = document.createElement("script")
  po.type = "text/javascript"
  po.async = true
  po.src = "https://apis.google.com/js/plusone.js"
  s = document.getElementsByTagName("script")[0]
  s.parentNode.insertBefore po, s
  
  # Twitter
  d = document
  s = "script"
  id = "twitter-wjs"
  js = undefined
  fjs = d.getElementsByTagName(s)[0]
  p = (if /^http:/.test(d.location) then "http" else "https")
  unless d.getElementById(id)
    js = d.createElement(s)
    js.id = id
    js.src = p + "://platform.twitter.com/widgets.js"
    fjs.parentNode.insertBefore js, fjs

# Re-render visualization template on window resize
Template.visualization.resize = ->
  if Session.get "resize" then return

# Render SVGs and ranked list based on current vizMode
Template.visualization.render_template = ->
  type = Session.get "vizType"
  switch type
    when "treemap"
      new Handlebars.SafeString(Template.treemap(this))
    when "matrix"
      new Handlebars.SafeString(Template.matrix(this))
    when "scatterplot"
      new Handlebars.SafeString(Template.scatterplot(this))
    when "map"
      new Handlebars.SafeString(Template.map(this))
    when "histogram"
      new Handlebars.SafeString(Template.histogram(this))
    when "stacked"
      new Handlebars.SafeString(Template.stacked(this))

Template.time_slider.rendered = ->
  $("select#from, select#to").selectToUISlider
    labels: 15
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

  accordion.accordion "resize"

Template.accordion.events = 
  "click li a": (d) ->
    srcE = (if d.srcElement then d.srcElement else d.target)
    vizType = $(srcE).data "viz-type"
    vizMode = $(srcE).data "viz-mode"

    # Parameters depend on vizMode (e.g countries -> languages for exports)
    [paramOne, paramTwo] = IOMapping[vizMode]["in"]

    # Reset parameters for a viz type change
    Router.go "observatory",
      vizType: vizType
      vizMode: vizMode
      paramOne: defaults[paramOne]
      paramTwo: defaults[paramTwo]
      from: defaults.from
      to: defaults.to
      langs: defaults.langs

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
  People.findOne @_id

Template.ranked_list.top10 = ->
  PeopleTop10.find {},
    sort:
      numlangs: -1

Template.ranked_list.empty = ->
  PeopleTop10.find().count() is 0

Template.ranked_person.birthday = ->
  birthday = (if (@birthyear < 0) then (@birthyear * -1) + " B.C." else @birthyear)
  birthday

Template.date_header.helpers
  from: ->
    from = Session.get("from")
    return "1 A.D."  if from is "1"
    (if (from < 0) then (from * -1) + " B.C." else from)

  to: ->
    to = Session.get("to")
    return "1 A.D."  if to is "1"
    (if (to < 0) then (to * -1) + " B.C." else to)


# Generate question given viz type
Template.question.question = ->
  try
    
    # TODO Make this not suck
    
    # s_domains = "in the area of " + s_domains.substring(1);
    
    # s_domain = "in the area of " + s_domain.substring(1);
    
    # s_domain = "in the area of " + s_domain.substring(1);
    boldify = (s) ->
      "<b>" + s + "</b>"
    s_countries = (if (Session.get("country") is "all") then "the world" else Countries.findOne(countryCode: Session.get("country")).countryName)
    s_countryX = (if (Session.get("countryX") is "all") then "the world" else Countries.findOne(countryCode: Session.get("countryX")).countryName)
    s_countryY = (if (Session.get("countryY") is "all") then "the world" else Countries.findOne(countryCode: Session.get("countryY")).countryName)
    s_domains = (if (Session.get("category") is "all") then "all domains" else decodeURIComponent(Session.get("category")))
    s_domainX = (if (Session.get("categoryX") is "all") then "all domains" else decodeURIComponent(Session.get("categoryX")))
    s_domainY = (if (Session.get("categoryY") is "all") then "all domains" else decodeURIComponent(Session.get("categoryY")))
    s_regions = (if (Session.get("language") is "all") then "the world" else Languages.findOne(lang: Session.get("language")))
    s_languageX = Languages.findOne(lang: Session.get("languageX"))
    s_languageY = Languages.findOne(lang: Session.get("languageY"))
    does_or_do = (if (Session.get("country") is "all") then "do" else "does")
    s_or_no_s_c = (if (Session.get("country") is "all") then "'" else "'s")
    s_or_no_s_r = (if (Session.get("language") is "all") then "'" else "'s")
    speakers_or_no_speakers = (if (Session.get("language") is "all") then "" else " speakers")
    gender = undefined
    gender_var = Session.get("gender")
    switch gender_var
      when "both"
        gender = "men and women"
      when "male"
        gender = "men"
      when "female"
        gender = "women"
      when "ratio"
        gender = "ratio of women to men"
    if s_domains.charAt(0) is "-"
      console.log s_domains.charAt(s_domains.length - 1)
      if s_domains.charAt(s_domains.length - 1) is "y"
        s_domains = s_domains.substring(1, s_domains.length - 1) + "ies"
      else
        s_domains = s_domains.substring(1) + "s"
    else s_domains = s_domains.substring(1)  if s_domains.charAt(0) is "+"
    if s_domainX.charAt(0) is "-"
      console.log s_domainX.charAt(s_domainX.length - 1)
      if s_domainX.charAt(s_domainX.length - 1) is "y"
        s_domainX = s_domainX.substring(1, s_domainX.length - 1) + "ies"
      else
        s_domainX = s_domainX.substring(1) + "s"
    if s_domainY.charAt(0) is "-"
      console.log s_domainY.charAt(s_domainY.length - 1)
      if s_domainY.charAt(s_domainY.length - 1) is "y"
        s_domainY = s_domainY.substring(1, s_domainY.length - 1) + "ies"
      else
        s_domainY = s_domainY.substring(1) + "s"
    s_domainX = s_domainX.substring(1)  if s_domainX.charAt(0) is "+"
    s_domainY = s_domainY.substring(1)  if s_domainY.charAt(0) is "+"
    type = Session.get("vizType")
    mode = Session.get("vizMode")
    switch mode
      when "country_exports"
        if type is "treemap"
          return new Handlebars.SafeString("Who are the cultural exports of " + boldify(s_countries) + "?")
        else if type is "histogram"
          return new Handlebars.SafeString("What is the comparative advantage of " + boldify(s_countries) + "?")
      when "country_imports"
        return new Handlebars.SafeString((if (Session.get("language") is "all") then "Who does " + boldify("the world") + " import?" else "What do " + boldify(s_regions) + " speakers import?"))
      when "domain_exports_to"
        if type is "treemap"
          return new Handlebars.SafeString("Who exports " + boldify(s_domains) + "?")
        else if type is "histogram"
          return new Handlebars.SafeString("Who has comparative advantage in " + boldify(s_domains) + "?")
      when "domain_imports_from"
        return new Handlebars.SafeString("Who imports " + boldify(s_domains) + "?")
      when "bilateral_exporters_of"
        return new Handlebars.SafeString("Who does " + boldify(s_countries) + " export to " + boldify(s_regions + speakers_or_no_speakers) + "?")
      when "bilateral_importers_of"
        return new Handlebars.SafeString("Where does " + boldify(s_countries) + " export " + boldify(s_domains) + " to?")
      when "matrix_exports"
        return new Handlebars.SafeString("Who " + boldify(gender) + " does " + boldify(s_countries) + " export?")
      when "country_vs_country"
        return new Handlebars.SafeString("Who does " + boldify(s_countryX) + " export compared to " + boldify(s_countryY) + "?")
      when "lang_vs_lang"
        return new Handlebars.SafeString("Who do " + boldify(s_languageX) + " speakers import compared to " + boldify(s_languageY) + " speakers?")
      when "domain_vs_domain"
        return new Handlebars.SafeString("Who exports " + boldify(s_domainX) + " compared to " + boldify(s_domainY) + "?")
      when "map"
        return new Handlebars.SafeString("Who exports " + boldify(s_domains) + "?")
#
# * TOOLTIPS
# 
Template.tooltip.helpers
  tooltipShown: ->
    Session.get "showTooltip"

  position: ->
    Session.get "tooltipPosition"

  top5: -> # Total count is also passed
    Tooltips.find _id:
      $not: "count"

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
