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

# Functions to return random entities
@getRandomFromArray = (arr) -> arr[Math.floor(arr.length * Math.random())]

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
    in: ["all", "all"]
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
  countriesOverTenPeople = ['US', 'GB', 'FR', 'DE', 'IT', 'RU', 'ES', 'TR', 'PL', 'AT', 'GR', 'IN', 'JP', 'SE', 'NL', 'BE', 'CN', 'HU', 'CH', 'CZ', 'UA', 'DK', 'BR', 'PT', 'EG', 'IR', 'CA', 'IE', 'NO', 'IL', 'FI', 'AR', 'RO', 'SA', 'AU', 'MX', 'RS', 'HR', 'ZA', 'LT', 'IQ', 'KR', 'PK', 'AF', 'PE', 'PH', 'DZ', 'GE', 'BG', 'CL', 'SY', 'TN', 'BY', 'LV', 'IS', 'EE', 'SK', 'NZ']
  topHundredPeople = ['Jesus Christ', 'Confucius', 'Isaac Newton', 'Wolfgang Amadeus Mozart', 'Leonardo Da Vinci', 'Adolf Hitler', 'Albert Einstein', 'Mustafa Kemal Atatürk', 'William Shakespeare', 'Michelangelo', 'Hebe Camargo', 'Vincent van Gogh', 'Christopher Columbus', 'Ludwig van Beethoven', 'Aristotle', 'Muhammad', 'Charles Darwin', 'Karl Marx', 'Galileo Galilei', 'Charlie Chaplin', 'Napoleon Bonaparte', 'Johann Sebastian Bach', 'Qin Shi Huang', 'George Bush', 'Pablo Picasso', 'Plato', 'Homer', 'Alexander the Great', 'Mahatma Gandhi', 'Dante', 'Socrates', 'Vladimir Lenin', 'Lech Wałęsa  Poland', 'George Washington', 'Joseph Stalin', 'Sigmund Freud', 'Nelson Mandela', 'Johann Wolfgang von Goethe', 'Abraham Lincoln', 'Marie Curie', 'Archimedes', 'Che Guevara', 'Julius Caesar', 'Miguel de Cervantes', 'Nicolaus Copernicus', 'Elizabeth II of the United Kingdom', 'Marco Polo', 'Thomas Edison', 'Immanuel Kant', 'Martin Luther', 'Rembrandt', 'Gautama Buddha', 'Carl Linnaeus', 'Leo Tolstoy', 'Pope Benedict', 'Victor Hugo', 'Mao Zedong', 'Salvador Dalí', 'Genghis Khan', 'Neil Armstrong', 'Ferdinand Magellan', 'Franz Kafka', 'René Descartes', 'Vasco da Gama', 'Yuri Gagarin', 'Bill Clinton', 'Elvis Presley', 'Roald Amundsen', 'Augustus', 'Euclid', 'Friedrich Nietzsche', 'Octave Mirbeau', 'Aleksandr Pushkin', 'Charlemagne  Belgium', 'Francisco Goya', 'John F. Kennedy', 'Louis Pasteur', 'Martin Luther King, Jr.', 'Richard Wagner', 'Charles Dickens', 'Fidel Castro', 'James Cook', 'James Joyce', 'Jean Auguste Dominique Ingres', 'Marlene Dietrich', 'Pythagoras', 'Virgil', 'Winston Churchill', 'Franklin D. Roosevelt', 'Fyodor Dostoyevsky', 'Thomas Jefferson', 'Walt Disney', 'Albrecht Dürer', 'Frida Kahlo', 'Raphael', 'Sarah Bernhardt', 'Simón Bolívar', 'Voltaire', 'Adam Smith']

  @defaults =
    vizType: "treemap"
    vizMode: "country_exports"
    country: getRandomFromArray(countriesOverTenPeople)
    countryX: getRandomFromArray(countriesOverTenPeople)
    countryY: getRandomFromArray(countriesOverTenPeople)
    language: "all"
    # languageX: "en"
    # languageY: "ru"
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
    person: getRandomFromArray(topHundredPeople)
    scatterplotScale: "linear"
    scatterplotMirror: true

  Session.setDefault "page", "observatory"
  Session.setDefault "vizType", defaults.vizType
  Session.setDefault "vizMode", defaults.vizMode
  Session.setDefault "country", defaults.country
  Session.setDefault "countryX", defaults.countryX
  Session.setDefault "countryY", defaults.countryY
  Session.setDefault "language", defaults.language
  # Session.setDefault "languageX", defaults.languageX
  # Session.setDefault "languageY", defaults.languageY
  Session.setDefault "category", defaults.category
  Session.setDefault "categoryX", defaults.categoryX
  Session.setDefault "categoryY", defaults.categoryY
  Session.setDefault "from", defaults.from
  Session.setDefault "to", defaults.to
  Session.setDefault "langs", defaults.langs
  Session.setDefault "categoryLevel", defaults.categoryLevel
  Session.setDefault "gender", defaults.gender
  Session.setDefault "dataset", defaults.dataset
  
  # MATRICES
  Session.setDefault "gender", "both"
  Session.setDefault "countryOrder", "count"
  Session.setDefault "industryOrder", "count"

  # SCATTERPLOT
  Session.setDefault "scatterplotScale", defaults.scatterplotScale
  Session.setDefault "scatterplotMirror", defaults.scatterplotMirror
  
  # TOOLTIPS
  Session.setDefault "hover", false
  Session.setDefault "showTooltip", false
  Session.setDefault "tooltipCategory", "all"
  Session.setDefault "tooltipCategoryLevel", "domain"
  Session.setDefault "tooltipCountryCode", "all"
  Session.setDefault "tooltipCountryCodeX", "all"
  Session.setDefault "tooltipCountryCodeY", "all"

  # RANKINGS
  Session.setDefault "entity", "people"
  
  # PEOPLE
  Session.setDefault "person", defaults.person

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
#   section: "Timeline"
#   template: "timeline"
#   url: "/timeline"
# ,
  # section: "Vision"
  # template: "vision"
  # url: "/vision"
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
  section: "References"
  template: "references"
  url: "/references"
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

Template.sharing_options.events = 

    "click a.google-plus-icon": ->
      width  = 575
      height = 400
      left   = ($(window).width()  - width)  / 2
      top    = ($(window).height() - height) / 2  # encodeURIComponent(location.href)
      url    = "https://plus.google.com/share?url=" + encodeURIComponent(location.href)
      opts   = 'status=1' +
             ',width='  + width  +
             ',height=' + height +
             ',top='    + top    +
             ',left='   + left

      window.open url, 'google', opts
      false

    "click a.facebook-icon": ->
      width  = 575
      height = 400
      left   = ($(window).width()  - width)  / 2
      top    = ($(window).height() - height) / 2  # encodeURIComponent(location.href)
      url    = "http://facebook.com/share.php?u=" + "Observatory of Global Culture" + "&url=" + encodeURIComponent(location.href)
      opts   = 'status=1' +
             ',width='  + width  +
             ',height=' + height +
             ',top='    + top    +
             ',left='   + left

      window.open url, 'facebook', opts
      false

    "click a.twitter-icon": ->
      question = $("#question").text()
      width  = 575
      height = 400
      left   = ($(window).width()  - width)  / 2
      top    = ($(window).height() - height) / 2  # encodeURIComponent(location.href)
      url    = "http://www.twitter.com/intent/tweet?text=" + question + "&url=" + encodeURIComponent(location.href) + "&hashtags=OGC, culture"
      opts   = 'status=1' +
             ',width='  + width  +
             ',height=' + height +
             ',top='    + top    +
             ',left='   + left

      window.open url, 'twitter', opts
      false

# https://twitter.com/intent/tweet?
# original_referer=https%3A%2F%2Fdev.twitter.com%2Fdocs%2Ftweet-button&text=Tweet%20Button%20%7C%20Twitter%20Developers&tw_p=tweetbutton&url=https%3A%2F%2Fdev.twitter.com&via=your_screen_name

# <a href="https://twitter.com/intent/tweet?original_referer=https%3A%2F%2Fdev.twitter.com%2Fdocs%2Ftweet-button&amp;text=Tweet%20Button%20%7C%20Twitter%20Developers&amp;tw_p=tweetbutton&amp;url=https%3A%2F%2Fdev.twitter.com&amp;via=your_screen_name" class="btn" id="b"><i></i><span class="label" id="l">Tweet</span></a>
#   # Twitter
#   d = document
#   s = "script"
#   id = "twitter-wjs"
#   js = undefined
#   fjs = d.getElementsByTagName(s)[0]
#   p = (if /^http:/.test(d.location) then "http" else "https")
#   unless d.getElementById(id)
#     js = d.createElement(s)
#     js.id = id
#     js.src = p + "://platform.twitter.com/widgets.js"
#     fjs.parentNode.insertBefore js, fjs

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