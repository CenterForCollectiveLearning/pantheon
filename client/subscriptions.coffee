# These are static data that never change
Meteor.subscribe "countries_pub"
Meteor.subscribe "languages_pub"
Meteor.subscribe "domains_pub"

# These subscriptions are explicitly global variables
allpeopleSub = Meteor.subscribe("allpeople")

# Derived Collections -- These are client only collections
# TODO: Do we need the @ sign here?
@PeopleTopN = new Meteor.Collection "peopleTopN"
@Treemap = new Meteor.Collection "treemap"
@CountriesRanking = new Meteor.Collection "countries_ranking"
@DomainsRanking = new Meteor.Collection "domains_ranking"
@Matrix = new Meteor.Collection "matrix"
@Scatterplot = new Meteor.Collection "scatterplot"
@WorldMap = new Meteor.Collection "worldmap"
@Histogram = new Meteor.Collection "histogram"
@Tooltips = new Meteor.Collection "tooltipCollection"
@Timeline = new Meteor.Collection "timeline"
@Stacked = new Meteor.Collection "stacked"

# People Page
@OccupationPeople = new Meteor.Collection "occupationPeople"
@BirthyearPeople = new Meteor.Collection "birthyearPeople"
@CountryPeople = new Meteor.Collection "countryPeople"
@PersonImports = new Meteor.Collection "person_imports"

# Subscription names ... TODO: do we need these?
top10Sub = null
dataSub = null
tooltipSub = null
tooltipCountSub = null
clicktooltipSub = null

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
  L = parseInt(Session.get("langs"))
  langs = true
  if L is null
    langs = false
  category = Session.get("category")
  categoryX = Session.get("categoryX")
  categoryY = Session.get("categoryY")
  gender = Session.get("gender")
  entity = Session.get("entity")

  occ = Session.get("occ")
  categoryLevel = Session.get("categoryLevel")

  # Changing Pages
  page = Session.get("page")

  # Changing Visualizations
  dataset = Session.get("dataset")
  vizType = Session.get("vizType")
  vizMode = Session.get("vizMode")

  # People Page
  personID = Session.get("personID")
  personOccupation = Session.get("personOccupation")
  personBirthyear = Session.get("personBirthyear")
  personCountry = Session.get("personCountry")

  console.log "vizType: " + vizType
  console.log "vizMode: " + vizMode
  console.log "begin: " + begin
  console.log "end: " + end
  console.log "L: " + L
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
  console.log "dataset: " + dataset
  
  #
  #        TODO this is probably not the right way to check if no data should be loaded.
  #        Do something more robust.
  #      
  if country and begin and end and langs
    
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
          top10Sub = Meteor.subscribe("peopleTopN", vizType, vizMode, begin, end, L, country, "both", category, categoryLevel, 10, dataset)
          dataSub = Meteor.subscribe("treemap_pub", vizMode, begin, end, L, country, language, category, categoryLevel, dataset, onReady)
        # Matrix modes
        when "matrix"
          top10Sub = Meteor.subscribe("peopleTopN", vizType, vizMode, begin, end, L, country, gender, category, categoryLevel, 10, dataset)
          dataSub = Meteor.subscribe("matrix_pub", begin, end, L, gender, dataset, onReady)
        # Scatterplot modes
        when "scatterplot"
          dataSub = Meteor.subscribe("scatterplot_pub", vizMode, begin, end, L, countryX, countryY, languageX, languageY, categoryX, categoryY, categoryLevel, dataset, onReady)
        # Map modes
        when "map"
          top10Sub = Meteor.subscribe("peopleTopN", vizType, vizMode, begin, end, L, country, "both", category, categoryLevel, 10, dataset)
          dataSub = Meteor.subscribe("map_pub", begin, end, L, category, categoryLevel, dataset, onReady)
        when "histogram"
          dataSub = Meteor.subscribe("histogram_pub", vizMode, begin, end, L, country, language, category, categoryLevel, onReady)
        when "stacked"
          top10Sub = Meteor.subscribe("peopleTopN", vizType, vizMode, begin, end, L, country, "both", category, categoryLevel, 10, dataset)
          dataSub = Meteor.subscribe("stacked_pub", vizMode, begin, end, L, country, language, category, categoryLevel, dataset, onReady)
        else
          console.log "Unsupported vizType"
    else if page is "rankings"
      switch entity
        when "countries"
          dataSub = Meteor.subscribe("countries_ranking_pub", begin, end, category, categoryLevel, L, onReady)
        when "people"
          dataSub = Meteor.subscribe("peopleTopN", vizType, vizMode, begin, end, L, country, "both", category, categoryLevel, "all", dataset, onReady)
        when "domains"
          dataSub = Meteor.subscribe("domains_ranking_pub", begin, end, country, category, categoryLevel, L, onReady)
        else
          console.log "Invalid ranking entity!"
    else if page is "timeline"
      dataSub = Meteor.subscribe("timeline_pub", begin, end, onReady)
    else if page is "people"
      console.log personOccupation, personBirthyear, personCountry
      if personID and personOccupation and personBirthyear and personCountry
        Meteor.subscribe("person_imports", personID)
        occDataSub = Meteor.subscribe("occupation_pub", personID, personOccupation, onReady)
        birthyearDataSub = Meteor.subscribe("birthyear_pub", personID, personBirthyear, onReady)
        countryDataSub = Meteor.subscribe("country_pub", personID, personCountry, onReady)

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
  showclicktooltip = Session.get("clicktooltip")
  return  unless hover or showclicktooltip
  Session.set "tooltipDataReady", false
  if hover
    category = Session.get("tooltipCategory")
    categoryLevel = Session.get("tooltipCategoryLevel")
    countryCode = Session.get("tooltipCountryCode")
    categoryX = Session.get("categoryX")
    categoryY = Session.get("categoryY")
    countryCodeX = Session.get("tooltipCountryCodeX")
    countryCodeY = Session.get("tooltipCountryCodeY")
  else if showclicktooltip #separate these session variables because hovering updates the tooltip ones
    category = Session.get("bigtooltipCategory")
    categoryLevel = Session.get("bigtooltipCategoryLevel")
    countryCode = Session.get("bigtooltipCountryCode")
    categoryX = Session.get("bigtooltipCategoryX")
    categoryY = Session.get("bigtooltipCategoryY")
    countryCodeX = Session.get("bigtooltipCountryCodeX")
    countryCodeY = Session.get("bigtooltipCountryCodeY")

  gender = Session.get("gender")
  begin = parseInt(Session.get("from"))
  end = parseInt(Session.get("to"))
  L = parseInt(Session.get("langs"))
  vizMode = Session.get("vizMode")
  dataset = Session.get("dataset")
  tooltipSub = Meteor.subscribe("tooltipPeople", vizMode, begin, end, L, countryCode, countryCodeX, countryCodeY, gender, category, categoryX, categoryY, categoryLevel, dataset, showclicktooltip, onDataReady)
