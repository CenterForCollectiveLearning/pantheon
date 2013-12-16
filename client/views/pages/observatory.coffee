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
      
Template.share_view.events =
  "mouseenter div.share-view": (d) ->
    srcE = (if d.srcElement then d.srcElement else d.target)
    $(srcE).find("a").animate({top: "-30px"}, 300)

  "mouseleave div.share-view": (d) ->
    srcE = (if d.srcElement then d.srcElement else d.target)
    $(srcE).find("a").animate({top: "0"}, 300)

Template.time_slider.rendered = ->
  # Not sure why this works, but it overcomes the re-styling issue
  $("div#from > select, div#to > select").selectToUISlider
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

  # accordion.accordion "resize"

Template.accordion.events = 
  "click li a": (d) ->
    srcE = (if d.srcElement then d.srcElement else d.target)
    vizType = $(srcE).data "viz-type"
    vizMode = $(srcE).data "viz-mode"

    # Parameters depend on vizMode (e.g countries -> languages for exports)
    [paramOne, paramTwo] = IOMapping[vizMode]["in"]
    unless paramOne is "all"
      paramOne = Session.get(paramOne)
    unless paramTwo is "all"
      paramTwo = Session.get(paramTwo)

    # Use session variables as parameters for a viz type change
    Router.go "observatory",
      vizType: vizType
      vizMode: vizMode
      paramOne: paramOne
      paramTwo: paramTwo
      from: Session.get("from")
      to: Session.get("to")
      langs: Session.get("langs")
      gender: Session.get("gender")
      dataset: Session.get("dataset")

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
  PeopleTopN.find()

Template.ranked_list.empty = ->
  PeopleTopN.find().count() is 0

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
  getQuestion()

@getQuestion = -> 
  boldify = (s) -> "<b>" + s + "</b>"
  s_countries = (if (Session.get("country") is "all") then "the world" else Countries.findOne(countryCode: Session.get("country")).countryName)
  s_countryX = (if (Session.get("countryX") is "all") then "the world" else Countries.findOne(countryCode: Session.get("countryX")).countryName)
  s_countryY = (if (Session.get("countryY") is "all") then "the world" else Countries.findOne(countryCode: Session.get("countryY")).countryName)
  s_domains = (if (Session.get("category") is "all") then "all domains" else decodeURIComponent(Session.get("category"))).capitalize()
  s_domainX = (if (Session.get("categoryX") is "all") then "all domains" else decodeURIComponent(Session.get("categoryX"))).capitalize()
  s_domainY = (if (Session.get("categoryY") is "all") then "all domains" else decodeURIComponent(Session.get("categoryY"))).capitalize()

  gender_var = Session.get("gender")
  switch gender_var
    when "both"
      gender = "men and women"
    when "male"
      gender = "men"
    when "female"
      gender = "women"
    when "ratio"
      gender = "women to men"

  # Switch based on categoryLevel: occupations are singular
  categoryLevel = Session.get("categoryLevel")
  if categoryLevel
    switch categoryLevel
      when "domain"
        category_prefix = " individuals in "
      when "industry"
        category_prefix = " individuals in "      
      when "occupation"
        category_prefix = ""
        if s_domains is "Martial Arts" then s_domains = "Martial Artists"
        else s_domains = s_domains + "s"
  else
    category_prefix = " individuals in "

  type = Session.get("vizType")
  mode = Session.get("vizMode")
  switch mode
    when "country_exports"
      if type is "treemap"
        return new Handlebars.SafeString("Who are the globally known people born in " + boldify(s_countries) + "?")
    when "country_imports"
      return new Handlebars.SafeString((if (Session.get("language") is "all") then "Who does " + boldify("the world") + " import?" else "What do " + boldify(s_regions) + " speakers import?"))
    when "domain_exports_to", "map"
      return new Handlebars.SafeString("Where are the globally known " + category_prefix + boldify(s_domains) + " born?")
    when "matrix_exports"
      if gender_var then result = "How is the ratio of " + boldify("women to men") + " distributed globally?"
      else result = "How are globally known " + boldify(gender) + " distributed?"
      return new Handlebars.SafeString(result)
    when "country_vs_country"
      return new Handlebars.SafeString("What globally known people were born in " + boldify(s_countryX) + " vs. " + boldify(s_countryY) + "?")
    when "domain_vs_domain"
      return new Handlebars.SafeString("How many globally known individuals are in the area of " + boldify(s_domainX) + " vs. " + boldify(s_domainY))

#
# TOOLTIPS
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

Template.tt_person.birthday = ->
  birthday = (if (@birthyear < 0) then (@birthyear * -1) + " B.C." else @birthyear)
  birthday

Template.clicktooltip.helpers
  showclicktooltip: ->
    Session.get "clicktooltip"
  categoryName : ->
    Session.get("bigtooltipCategory").capitalize()
  category : ->
    Session.get("bigtooltipCategory")
  from : ->
    Session.get("from")
  to : ->
    Session.get("to")
  L : ->
    Session.get("langs")
  dataset : ->
    Session.get("dataset")
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

Template.domain_exporter_question.categoryName = ->
    Session.get("bigtooltipCategory").capitalize()

Template.country_exports_question.countryName = ->
  countryCode = Session.get("tooltipCountryCode")
  dataset = Session.get("dataset")
  vizMode = Session.get("vizMode")
  if vizMode is "map" and dataset is "murray"
    return (Countries.findOne({countryCode3: countryCode}).countryName).capitalize()
  else
    return (Countries.findOne({countryCode: countryCode, dataset: dataset}).countryName).capitalize() 

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

Template.clicktooltip.events =
  "click .d3plus_tooltip_close,.d3plus_tooltip_curtain": (d) ->
    $("#clicktooltip").fadeOut()
    Session.set "clicktooltip", false
  "click .closeclicktooltip": (d) ->
    $("#clicktooltip").fadeOut()
    Session.set "clicktooltip", false

# Template.tt_table.rendered = ->
#   data = _.map Tooltips.find({_id:{$not:"count"}}).fetch(), (d) ->
#         p = People.findOne d._id
#         [0, p.name, p.countryName, p.birthyear, p.gender, p.occupation.capitalize(), p.numlangs]
#       aoColumns = [
#         sTitle: "Ranking"
#       ,
#         sTitle: "Name"
#         fnRender: (obj) -> "<a class='closeclicktooltip' href='/people/" + obj.aData[obj.iDataColumn] + "'>" + obj.aData[obj.iDataColumn] + "</a>"  # Insert route here
#       ,
#         sTitle: "Country"
#       ,
#         sTitle: "Birth Year"
#       ,
#         sTitle: "Gender"
#       ,
#         sTitle: "Occupation"
#       ,
#         sTitle: "L"
#       ]
#   #initializations
#   $("#tt_table").dataTable
#     aaData: data
#     aoColumns: aoColumns
#     iDisplayLength: 10
#     bDeferRender: true
#     bSortClasses: false
#     fnDrawCallback: (oSettings) ->
#       that = this
#       if oSettings.bSorted
#         @$("td:first-child",
#           filter: "applied"
#         ).each (i) ->
#           that.fnUpdate i + 1, @parentNode, 0, false, false
#     aaSorting: [[6, "desc"]]

  # $("#tt_table").dataTable
  #   bFilter: false
  #   bInfo: false
  #   bLengthChange: false    
  #   iDisplayLength: 10
  #   bDeferRender: true
  #   fnDrawCallback: (oSettings) ->
  #     that = this
  #     if oSettings.bSorted
  #       @$("td:first-child",
  #         filter: "applied"
  #       ).each (i) ->
  #         that.fnUpdate i + 1, @parentNode, 0, false, false
  #   aoColumnDefs: [
  #     bSortable: false
  #     aTargets: [0]
  #   ]
  #   aaSorting: [[6, "desc"]]
