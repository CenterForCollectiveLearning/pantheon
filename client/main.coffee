# Set Defaults
@getCategoryLevel = (s) ->
  domains = Domains.find().fetch()
  for i of domains
    domain_obj = domains[i]
    return "domain"  if domain_obj.domain is s
    return "industry"  if domain_obj.industry is s
    return "occupation"  if domain_obj.occupation is s

@String::capitalize = ->
  # Match letters at beginning of string or after white space character
  @toLowerCase().replace /(?:^|\s)\S/g, (a) ->
    a.toUpperCase()

# Enable caching for getting readrboard script
jQuery.cachedScript = (url, options) ->
  
  # Allow user to set any option except for dataType, cache, and url
  options = $.extend(options or {},
    dataType: "script"
    cache: true
    url: url
  )
  
  # Use $.ajax() since it is more flexible than $.getScript
  # Return the jqXHR object so we can chain callbacks
  jQuery.ajax options

@defaults =
  vizType: "treemap"
  vizMode: "country_exports"
  country: "all"
  countryX: "US"
  countryY: "RU"
  language: "all"
  languageX: "en"
  languageY: "ru"
  category: "all"
  categoryX: "ARTS"
  categoryY: "HUMANITIES"
  categoryLevel: "domain"
  from: "-3000"
  to: "1950"
  langs: "25"
  entity: "countries"
  gender: "both"
  dataset: "OGC"

@IOMapping =
  country_exports:
    in: ["country", "language"]
    out: "category"

  country_imports:
    in: ["language", "country"]
    out: "category"

  domain_exports_to:
    in: ["category", "language"]
    out: "country"

  domain_imports_from:
    in: ["category", "country"]
    out: "language"

  bilateral_exporters_of:
    in: ["country", "language"]
    out: "category"

  bilateral_importers_of:
    in: ["country", "category"]
    out: "language"

  matrix_exports:
    in: ["country", "category"]
    out: "language"

  country_vs_country:
    in: ["countryX", "countryY"]
    out: "category"

  domain_vs_domain:
    in: ["categoryX", "categoryY"]
    out: "country"

  lang_vs_lang:
    in: ["languageX", "languageY"]
    out: "category"

  map:
    in: ["category", "language"]
    out: "country"


# Object containing domain hierarchy for domains dropdown
@uniqueDomains = []
@indByDom = {}
@occByInd = {}
Meteor.startup ->
  
  # # Get client location
  # if navigator.geolocation
  #   console.log "GEOLOCATION WORKS"
  #   navigator.geolocation.getCurrentPosition (position) ->
  #     console.log position
  #     $.getJSON "http://ws.geonames.org/countryCode",
  #       lat: position.coords.latitude
  #       lng: position.coords.longitude
  #       type: "JSON"
  #     , (result) ->
  #       defaults.countryCode = result.countryCode
  #       Session.set "country", result.countryCode

  Session.setDefault "country", defaults.countryCode

  Session.setDefault "page", "observatory"
  Session.setDefault "vizType", defaults.vizType
  Session.setDefault "vizMode", defaults.vizMode
  Session.setDefault "country", defaults.country
  Session.setDefault "countryX", defaults.countryX
  Session.setDefault "countryY", defaults.countryY
  Session.setDefault "language", defaults.language
  Session.setDefault "languageX", defaults.languageX
  Session.setDefault "languageY", defaults.languageY
  Session.setDefault "category", defaults.category
  Session.setDefault "categoryX", defaults.categoryX
  Session.setDefault "categoryY", defaults.categoryY
  Session.setDefault "from", defaults.from
  Session.setDefault "to", defaults.to
  Session.setDefault "langs", defaults.langs
  Session.setDefault "occ", "all"
  Session.setDefault "categoryLevel", defaults.categoryLevel
  Session.setDefault "gender", defaults.gender
  Session.setDefault "dataset", defaults.dataset
  
  # MATRICES
  Session.setDefault "gender", "both"
  Session.setDefault "countryOrder", "count"
  Session.setDefault "industryOrder", "count"
  
  # TOOLTIPS
  Session.setDefault "hover", false
  Session.setDefault "showTooltip", false
  Session.setDefault "tooltipCategory", "all"
  Session.setDefault "tooltipCategoryLevel", "domain"
  Session.setDefault "tooltipCountryCode", "all"
  Session.setDefault "tooltipCountryCodeX", "all"
  Session.setDefault "tooltipCountryCodeY", "all"
  
  # SPLASH SCREEN
  Session.set "googleAnalytics", false
  Session.set "showSpinner", false

  # Set session variable if window resized (throttled rate)
  throttledResize = _.throttle(->
    Session.set "resize", new Date()
  , 50)
  $(window).resize throttledResize

Template.google_analytics.rendered = ->
  unless Session.get("googleAnalytics")
    console.log "RENDERING GOOGLE ANALYTICS"
    i = window
    s = document
    o = "script"
    g = "//www.google-analytics.com/analytics.js"
    r = "ga"
    i["GoogleAnalyticsObject"] = r
    i[r] = i[r] or ->
      (i[r].q = i[r].q or []).push arguments

    i[r].l = 1 * new Date()

    a = s.createElement(o)
    m = s.getElementsByTagName(o)[0]

    a.async = 1
    a.src = g
    m.parentNode.insertBefore a, m
    ga "create", "UA-44888546-1", "mit.edu"
    ga "send", "pageview"
  Session.set "googleAnalytics", true

Template.google_analytics.destroyed = ->
  Session.set "googleAnalytics", false

# Section Navigation
# TODO Is this repetitiveness necessary for correct formatting?
leftSections = [
  section: "Observatory"
  template: "observatory"
  url: "/observatory"
,
  section: "Rankings"
  template: "rankings"
  url: "/rankings"
,
  section: "People",
  template: "people",
  url: "/people"
,
  section: "Timeline"
  template: "timeline"
  url: "/timeline"
,
  section: "Vision"
  template: "vision"
  url: "/vision"
]

rightSections = [
  section: "Data"
  template: "data"
  url: "/data"
,
  
  # {
  #     section: "Publications",
  #     template: "publications",
  #     url: "/publications"
  # },
  section: "FAQ"
  template: "faq"
  url: "/faq"
,
  section: "Team"
  template: "team"
  url: "/team"
]
Template.nav.helpers
  leftSections: leftSections
  rightSections: rightSections

Template.section.helpers selected: ->
  (if Session.equals("page", @template) then "selected_section" else "")

Template.spinner.rendered = ->
  unless Session.get("showSpinner")
    console.log "RENDERING SPINNER"
    $("header").css "border-bottom-width", "0px"
    NProgress.configure
      minimum: 0.2
      trickleRate: 0.1
      trickleSpeed: 500

    NProgress.start()
  Session.set "showSpinner", true

Template.spinner.destroyed = ->
  NProgress.done()
  $("header").css "border-bottom-width", "3px"
  Session.set "showSpinner", false