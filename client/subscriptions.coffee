# These are static data that never change
Meteor.subscribe "countries_pub"
Meteor.subscribe "languages_pub"
Meteor.subscribe "domains_pub"

# These subscriptions are explicitly global variables
allpeopleSub = Meteor.subscribe("allpeople")

# These are client only collections
top10Sub = null
dataSub = null
tooltipSub = null
tooltipCountSub = null

#
#Subscription for the current data that is being visualized
# 
Deps.autorun ->
  country = Session.get("country")
  countryX = Session.get("countryX")
  countryY = Session.get("countryY")
  language = Session.get("language")
  languageX = Session.get("languageX")
  languageY = Session.get("languageY")
  begin = parseInt(Session.get("from"))
  end = parseInt(Session.get("to"))
  langs = parseInt(Session.get("langs"))
  category = Session.get("category")
  categoryX = Session.get("categoryX")
  categoryY = Session.get("categoryY")
  gender = Session.get("gender")
  entity = Session.get("entity")
  page = Session.get("page")
  category = category  if category
  occ = Session.get("occ")
  vizMode = Session.get("vizMode")
  vizType = Session.get("vizType")
  categoryLevel = Session.get("categoryLevel")
  
  #
  #        TODO this is probably not the right way to check if no data should be loaded.
  #        Do something more robust.
  #      
  unless not country or not begin or not end or not langs
    
    #
    #         Do nothing:
    #
    #         It's not necessary to track/stop subscriptions (i.e. those below)
    #          that are called inside an autorun computation.
    #         See http://docs.meteor.com/#meteor_subscribe
    #
    #         We verified this by going from map to treemap back to map while checking
    #          the PeopleTop10 collection on the client. it goes from 0 -> 10 -> 0.
    #         
    console.log "SUBSCRIBING"
    Session.set "dataReady", false
    
    # This gets passed to the subscriptions to indicate when data is ready
    onReady = ->
      Session.set "dataReady", true
      Session.set "initialDataReady", true

    
    # Give a handle to this subscription so we can check if it's ready
    if page is "observatory"
      switch vizType
        # Treemap modes
        when "treemap"
          top10Sub = Meteor.subscribe("peopletop10", begin, end, langs, country, category, categoryLevel)
          dataSub = Meteor.subscribe("treemap_pub", vizMode, begin, end, langs, country, language, category, categoryLevel, onReady)
        # Matrix modes
        when "matrix"
          dataSub = Meteor.subscribe("matrix_pub", begin, end, langs, gender, onReady)
        # Scatterplot modes
        when "scatterplot"
          dataSub = Meteor.subscribe("scatterplot_pub", vizMode, begin, end, langs, countryX, countryY, languageX, languageY, categoryX, categoryY, categoryLevel, onReady)
        # Map modes
        when "map"
          dataSub = Meteor.subscribe("map_pub", begin, end, langs, category, categoryLevel, onReady)
        when "stacked"
          top10Sub = Meteor.subscribe("peopletop10", begin, end, langs, country, category, categoryLevel)
          dataSub = Meteor.subscribe("stacked_pub", vizMode, begin, end, langs, country, language, category, categoryLevel, onReady)
        else
          console.log "Unsupported vizMode"
    else if page is "rankings"
      switch entity
        when "countries"
          dataSub = Meteor.subscribe("countries_ranking_pub", begin, end, category, categoryLevel, onReady)
        when "people"
          dataSub = Meteor.subscribe("peopletopN", begin, end, langs, country, category, categoryLevel, "all", onReady)
        when "domains"
          dataSub = Meteor.subscribe("domains_ranking_pub", begin, end, country, category, categoryLevel, onReady)
        else
          console.log "Invalid ranking entity!"
    else if page is "timeline"
      dataSub = Meteor.subscribe("timeline_pub", begin, end, onReady)
    console.log "vizMode: " + vizMode
    console.log "begin: " + begin
    console.log "end: " + end
    console.log "L: " + langs
    console.log "country: " + country
    console.log "countryX: " + countryX
    console.log "countryY: " + countryY
    console.log "languageX: " + languageX
    console.log "languageY: " + languageY
    console.log "language: " + language
    console.log "category: " + category
    console.log "categoryLevel: " + categoryLevel
    console.log "gender: " + gender
    console.log "entity: " + entity
    console.log "page: " + page


#
# Subscription for tooltips on hover
#  
Deps.autorun ->
  # Don't proceed if you're not hovering
  
  # get rid of people and count ready once tooltip is working
  # Return both in one publication
  onDataReady = ->
    Session.set "tooltipDataReady", true
  hover = Session.get("hover")
  return  unless hover
  Session.set "tooltipDataReady", false
  category = Session.get("tooltipCategory")
  categoryX = Session.get("categoryX")
  categoryY = Session.get("categoryY")
  categoryLevel = Session.get("tooltipCategoryLevel")
  countryCode = Session.get("tooltipCountryCode")
  countryCodeX = Session.get("tooltipCountryCodeX")
  countryCodeY = Session.get("tooltipCountryCodeY")
  gender = Session.get("gender")
  begin = parseInt(Session.get("from"))
  end = parseInt(Session.get("to"))
  langs = parseInt(Session.get("langs"))
  vizMode = Session.get("vizMode")
  tooltipSub = Meteor.subscribe("tooltipPeople", vizMode, begin, end, langs, countryCode, countryCodeX, countryCodeY, gender, category, categoryX, categoryY, categoryLevel, onDataReady)
