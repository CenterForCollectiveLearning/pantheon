# These are static data that never change
Meteor.subscribe "countries_pub"
Meteor.subscribe "domains_pub"

# These subscriptions are explicitly global variables
# allpeopleSub = Meteor.subscribe("allpeople")

# Derived Collections -- These are client only collections
@PeopleTopN = new Meteor.Collection "peopleTopN"
@Treemap = new Meteor.Collection "treemap"
@CountriesRanking = new Meteor.Collection "countries_ranking"
@DomainsRanking = new Meteor.Collection "domains_ranking"
@Matrix = new Meteor.Collection "matrix"
@Scatterplot = new Meteor.Collection "scatterplot"
@WorldMap = new Meteor.Collection "worldmap"
@Histogram = new Meteor.Collection "histogram"
@Tooltips = new Meteor.Collection "tooltipCollection"
# @Timeline = new Meteor.Collection "timeline"
# @Stacked = new Meteor.Collection "stacked"
@ClientPeople = new Meteor.Collection()

# People Page
@SimilarPeople = new Meteor.Collection "similarPeople"
@PersonImports = new Meteor.Collection "person_imports"

dataSub = null

#
#Subscription for the current data that is being visualized
# 
Deps.autorun ->
  country = Session.get("country")
  countryX = Session.get("countryX")
  countryY = Session.get("countryY")
  begin = parseInt(Session.get("from"))
  end = parseInt(Session.get("to"))
  L = Session.get("langs")
  langs = if L is null then false else true
  category = Session.get("category")
  categoryX = Session.get("categoryX")
  categoryY = Session.get("categoryY")
  gender = Session.get("gender")
  entity = Session.get("entity")

  occ = Session.get("occ")
  categoryLevel = Session.get("categoryLevel")
  categoryLevelX = Session.get("categoryLevelX")
  categoryLevelY = Session.get("categoryLevelY")

  # People Page
  personName = Session.get("name")
  rankingProperty = Session.get("rankingProperty")

  # Changing Pages
  page = Session.get("page")

  # Changing Visualizations
  dataset = Session.get("dataset")
  vizType = Session.get("vizType")
  vizMode = Session.get("vizMode")

  # console.log "vizType: " + vizType
  # console.log "vizMode: " + vizMode
  # console.log "begin: " + begin
  # console.log "end: " + end
  # console.log "L: " + L
  # console.log "country: " + country
  # console.log "countryX: " + countryX
  # console.log "countryY: " + countryY
  # console.log "category: " + category
  # console.log "categoryLevel: " + categoryLevel
  # console.log "categoryLevelX: " + categoryLevelX
  # console.log "categoryLevelY: " + categoryLevelY
  # console.log "gender: " + gender
  # console.log "entity: " + entity
  # console.log "page: " + page
  # console.log "dataset: " + dataset  
  #
  #        TODO this is probably not the right way to check if no data should be loaded.
  #        Do something more robust.
  #      
  # if country and begin and end and langs   
  if page in ["visualizations", "rankings", "people"]
    dataSub?.stop()
    Session.set "dataReady", false
    
    # This gets passed to the subscriptions to indicate when data is ready
    onReady = ->
      Session.set "dataReady", true
      Session.set "initialDataReady", true

    # Give a handle to this subscription so we can check if it's ready
    # TODO Move these into an underscore partial to avoid passing so many arguments
    if page is "visualizations"
      switch vizType
        # Treemap modes
        when "treemap"
          top10Sub = Meteor.subscribe("peopleTopN", vizType, vizMode, begin, end, L, country, countryX, countryY, "both", category, categoryX, categoryY, categoryLevel, categoryLevelX, categoryLevelY, 10, dataset)
          dataSub = Meteor.subscribe("treemap_pub", vizMode, begin, end, L, country, category, categoryLevel, dataset, onReady)
        # Matrix modes
        when "matrix"
          top10Sub = Meteor.subscribe("peopleTopN", vizType, vizMode, begin, end, L, country, countryX, countryY, gender, category, categoryX, categoryY, categoryLevel, categoryLevelX, categoryLevelY, 10, dataset)
          dataSub = Meteor.subscribe("matrix_pub", begin, end, L, gender, dataset, onReady)
        # Scatterplot modes
        when "scatterplot"
          top10Sub = Meteor.subscribe("peopleTopN", vizType, vizMode, begin, end, L, country, countryX, countryY, "both", category, categoryX, categoryY, categoryLevel, categoryLevelX, categoryLevelY, 10, dataset)
          dataSub = Meteor.subscribe("scatterplot_pub", vizMode, begin, end, L, countryX, countryY, categoryX, categoryY, categoryLevelX, categoryLevelY, dataset, onReady)
        # Map modes
        when "map"
          top10Sub = Meteor.subscribe("peopleTopN", vizType, vizMode, begin, end, L, country, countryX, countryY, "both", category, categoryX, categoryY, categoryLevel, categoryLevelX, categoryLevelY, 10, dataset)
          dataSub = Meteor.subscribe("map_pub", begin, end, L, category, categoryLevel, dataset, onReady)
        else
          console.log "Unsupported vizType"
    else if page is "rankings"
      switch entity
        when "countries"
          dataSub = Meteor.subscribe("countries_ranking_pub", begin, end, category, categoryLevel, L, onReady)
          # vizSub = Meteor.subscribe("treemap_pub", vizMode, begin, end, L, country, category, "industry", dataset, onReady)
        when "people"
          # usig ClientPeople instead of peopleTopN
          # defer onReady to make sure all people are loaded before rendering the datatable
          Meteor.defer onReady
        when "domains"
          dataSub = Meteor.subscribe("domains_ranking_pub", begin, end, country, category, categoryLevel, L, onReady)
        else
          console.log "Invalid ranking entity!"
    else if page is "people"
      dataSub = Meteor.subscribe("similar_people_pub", personName, rankingProperty, onReady)

#      
# Subscription for tooltips on hover
#  
Deps.autorun ->
  # Don't proceed if you're not hovering
  
  # get rid of people and count ready once tooltip is working
  # Return both in one publication
  onDataReady = -> Session.set "tooltipDataReady", true
  hover = Session.get("hover")
  showclicktooltip = Session.get("clicktooltip")
  return unless hover or showclicktooltip
  Session.set "tooltipDataReady", false

  if hover
    category = Session.get("tooltipCategory")
    categoryLevel = Session.get("tooltipCategoryLevel")
    countryCode = Session.get("tooltipCountryCode")
    categoryX = Session.get("categoryX")
    categoryY = Session.get("categoryY")
    categoryLevelX = Session.get("categoryLevelX")
    categoryLevelY = Session.get("categoryLevelY")
    countryCodeX = Session.get("tooltipCountryCodeX")
    countryCodeY = Session.get("tooltipCountryCodeY")
  else if showclicktooltip #separate these session variables because hovering updates the tooltip ones
    category = Session.get("bigtooltipCategory")
    categoryLevel = Session.get("bigtooltipCategoryLevel")
    countryCode = Session.get("bigtooltipCountryCode")
    categoryX = Session.get("bigtooltipCategoryX")
    categoryY = Session.get("bigtooltipCategoryY")
    categoryLevelX = Session.get("bigtooltipCategoryLevelX")
    categoryLevelY = Session.get("bigtooltipCategoryLevelY")
    countryCodeX = Session.get("bigtooltipCountryCodeX")
    countryCodeY = Session.get("bigtooltipCountryCodeY")

  gender = Session.get("gender")
  begin = parseInt(Session.get("from"))
  end = parseInt(Session.get("to"))
  L = Session.get("langs")
  vizMode = Session.get("vizMode")
  dataset = Session.get("dataset")

  if Session.equals("vizMode", "map") and Session.equals("category", "all")
    city = Session.get("tooltipCity")
  else
    city = "all"

  debouncedSubscribe = _.debounce(Meteor.subscribe, 500)
  # tooltipSub = debouncedSubscribe("tooltipPeople", vizMode, begin, end, L, countryCode, countryCodeX, countryCodeY, gender, category, categoryX, categoryY, categoryLevel, categoryLevelX, categoryLevelY, dataset, showclicktooltip, onDataReady)
  tooltipSub = Meteor.subscribe("tooltipPeople", vizMode, begin, end, L, countryCode, countryCodeX, countryCodeY, gender, category, categoryX, categoryY, categoryLevel, categoryLevelX, categoryLevelY, dataset, showclicktooltip, city, onDataReady)
