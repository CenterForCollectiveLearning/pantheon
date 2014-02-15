# Set Defaults
@getCategoryLevel = (s) ->
  domains = Domains.find({dataset: Session.get("dataset")}).fetch()
  for i of domains
    domain_obj = domains[i]
    return "domain"  if domain_obj.domain is s
    return "industry"  if domain_obj.industry is s
    return "occupation"  if domain_obj.occupation is s

# Detect Mobile Browser
@mobileBrowser = ((a) -> /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(a) or /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4))) navigator.userAgent or navigator.vendor or window.opera

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
    in: ["all", "gender"]
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

# static lists of category mappings
@mpdomains = #keys are pantheon, values are murray
  "FINE ARTS" : "VISUAL ARTS"
  "ASTRONOMER" : "ASTRONOMY"
  "BIOLOGIST" : "BIOLOGY"
  "CHEMIST" : "CHEMISTRY"
  "GEOLOGIST" : "EARTH SCIENCES"
  "LANGUAGE" : "LITERATURE"
  "MATH" : "MATHEMATICS"
  "MEDICINE" : "MEDICINE"
  "MUSIC" : "MUSIC"
  "PHILOSOPHY" : "PHILOSOPHY"
  "PHYSICIST" : "PHYSICS"
  "NATURAL SCIENCES" : "SCIENCE"
  "INVENTION" : "TECHNOLOGY"

@pantheonCountries = ['AD','AE','AF','AG','AL','AM','AO','AR','AT','AU','AW','AZ','BA','BB','BD','BE','BF','BG','BH','BI','BJ','BM','BN','BO','BR','BT','BW','BY','CA','CD','CF','CG','CH','CI','CL','CM','CN','CO','CR','CU','CV','CY','CZ','DE','DJ','DK','DO','DZ','EC','EE','EG','ER','ES','ET','FI','FM','FO','FR','GA','GB','GE','GF','GH','GI','GL','GM','GN','GP','GQ','GR','GT','GU','GW','GY','HK','HN','HR','HT','HU','ID','IE','IL','IM','IN','IQ','IR','IS','IT','JE','JM','JO','JP','KE','KG','KH','KN','KP','KR','KW','KZ','LA','LB','LC','LK','LR','LS','LT','LU','LV','LY','MA','MC','MD','ME','MG','MK','ML','MM','MN','MQ','MR','MT','MU','MV','MW','MX','MY','MZ','NA','NC','NE','NG','NI','NL','NO','NP','NR','NZ','OM','PA','PE','PH','PK','PL','PR','PS','PT','PY','QA','RO','RS','RU','RW','SA','SB','SC','SD','SE','SG','SI','SK','SL','SN','SO','SR','SS','ST','SV','SY','SZ','TD','TG','TH','TJ','TL','TM','TN','TO','TR','TT','TW','TZ','UA','UG','UNK','US','UY','UZ','VE','VI','VN','VU','WS','XK','YE','ZA','ZM','ZW']
@murrayCountries = ['AT','AU','Anc Greece','Arab World','BE','Balkans','CA','CH','CN','CZ','DE','DK','ES','FI','FR','GB','HU','IN','IS','IT','JP','Latin Am','NL','NO','NZ','PL','PT','RU','SE','SK','SS Africa','US']
@countriesOverTenPeople = ['US', 'GB', 'FR', 'DE', 'IT', 'RU', 'ES', 'TR', 'PL', 'AT', 'GR', 'IN', 'JP', 'SE', 'NL', 'BE', 'CN', 'HU', 'CH', 'CZ', 'UA', 'DK', 'BR', 'PT', 'EG', 'IR', 'CA', 'IE', 'NO', 'IL', 'FI', 'AR', 'RO', 'SA', 'AU', 'MX', 'RS', 'HR', 'ZA', 'LT', 'IQ', 'KR', 'PK', 'AF', 'PE', 'PH', 'DZ', 'GE', 'BG', 'CL', 'SY', 'TN', 'BY', 'LV', 'IS', 'EE', 'SK', 'NZ']
@topHundredPeople = ['Jesus Christ', 'Confucius', 'Isaac Newton', 'Wolfgang Amadeus Mozart', 'Leonardo Da Vinci', 'Adolf Hitler', 'Albert Einstein', 'Mustafa Kemal Atatürk', 'William Shakespeare', 'Michelangelo', 'Hebe Camargo', 'Vincent van Gogh', 'Christopher Columbus', 'Ludwig van Beethoven', 'Aristotle', 'Muhammad', 'Charles Darwin', 'Karl Marx', 'Galileo Galilei', 'Charlie Chaplin', 'Napoleon Bonaparte', 'Johann Sebastian Bach', 'Qin Shi Huang', 'George Bush', 'Pablo Picasso', 'Plato', 'Homer', 'Alexander the Great', 'Mahatma Gandhi', 'Dante', 'Socrates', 'Vladimir Lenin', 'Lech Wałęsa  Poland', 'George Washington', 'Joseph Stalin', 'Sigmund Freud', 'Nelson Mandela', 'Johann Wolfgang von Goethe', 'Abraham Lincoln', 'Marie Curie', 'Archimedes', 'Che Guevara', 'Julius Caesar', 'Miguel de Cervantes', 'Nicolaus Copernicus', 'Elizabeth II of the United Kingdom', 'Marco Polo', 'Thomas Edison', 'Immanuel Kant', 'Martin Luther', 'Rembrandt', 'Gautama Buddha', 'Carl Linnaeus', 'Leo Tolstoy', 'Pope Benedict', 'Victor Hugo', 'Mao Zedong', 'Salvador Dalí', 'Genghis Khan', 'Neil Armstrong', 'Ferdinand Magellan', 'Franz Kafka', 'René Descartes', 'Vasco da Gama', 'Yuri Gagarin', 'Bill Clinton', 'Elvis Presley', 'Roald Amundsen', 'Augustus', 'Euclid', 'Friedrich Nietzsche', 'Octave Mirbeau', 'Aleksandr Pushkin', 'Charlemagne  Belgium', 'Francisco Goya', 'John F. Kennedy', 'Louis Pasteur', 'Martin Luther King, Jr.', 'Richard Wagner', 'Charles Dickens', 'Fidel Castro', 'James Cook', 'James Joyce', 'Jean Auguste Dominique Ingres', 'Marlene Dietrich', 'Pythagoras', 'Virgil', 'Winston Churchill', 'Franklin D. Roosevelt', 'Fyodor Dostoyevsky', 'Thomas Jefferson', 'Walt Disney', 'Albrecht Dürer', 'Frida Kahlo', 'Raphael', 'Sarah Bernhardt', 'Simón Bolívar', 'Voltaire', 'Adam Smith']

# Object containing domain hierarchy for domains dropdown
@uniqueDomains = []
@indByDom = {}
@occByInd = {}
Meteor.startup ->
  # settings =
  #   logUser: true
  #   logHttp: true
  #   logDDP: true
  # Observatory.setSettings(settings)
  # Observatory.logTemplates()
  # Observatory.logCollection()
  # Observatory.logMeteor()

  @defaults =
    vizType: "treemap"
    vizMode: "country_exports"
    country: getRandomFromArray(countriesOverTenPeople)
    countryX: getRandomFromArray(countriesOverTenPeople)
    countryY: getRandomFromArray(countriesOverTenPeople)
    language: "all"
    category: "all"
    categoryX: "ARTS"
    categoryY: "HUMANITIES"
    categoryLevel: "domain"
    from: "-4000"
    to: "2010"
    langs: "H0"
    entity: "countries"
    gender: "both"
    dataset: "OGC"
    person: getRandomFromArray(topHundredPeople)
    scatterplotScale: "linear"
    scatterplotMirror: true
    rankingProperty: "occupation"

  Session.setDefault "page", "explore"
  Session.setDefault "vizType", defaults.vizType
  Session.setDefault "vizMode", defaults.vizMode
  Session.setDefault "country", defaults.country
  Session.setDefault "countryX", defaults.countryX
  Session.setDefault "countryY", defaults.countryY
  Session.setDefault "language", defaults.language
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
  Session.setDefault "tooltipTime", 0
  Session.setDefault "showTooltip", false
  Session.setDefault "clicktooltip", false
  Session.setDefault "tooltipCategory", "all"
  Session.setDefault "tooltipCategoryLevel", "domain"
  Session.setDefault "tooltipCountryCode", "all"
  Session.setDefault "tooltipCountryCodeX", "all"
  Session.setDefault "tooltipCountryCodeY", "all"

  # RANKINGS
  Session.setDefault "entity", "people"
  
  # PEOPLE
  Session.setDefault "person", defaults.person
  Session.setDefault "rankingProperty", defaults.rankingProperty

  # Set session variable if window resized (throttled rate) and window outerwidth greater than 1024px
  # Note: Doesn't recall subscription/publication, so short throttle time is OK
  throttledResize = _.throttle(->
    if window.outerWidth > 1024
      Session.set "resize", new Date()
  , 50)
  $(window).resize throttledResize

Template.google_analytics.rendered = ->
  unless Session.get("googleAnalytics")
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
  section: "Explore"
  template: "explore"
  url: "/explore"
,
  section: "Rankings"
  template: "rankings"
  url: "/rankings"
,
  section: "People",
  template: "people",
  url: "/people"
,
]

rightSections = [
  section: "Methods"
  template: "methods"
  url: "/methods"
,
  section: "Vision"
  template: "vision"
  url: "/vision"
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

    "click a.email-icon": ->
      question = $("#question").text()
      width  = 575
      height = 400
      left   = ($(window).width()  - width)  / 2
      top    = ($(window).height() - height) / 2  # encodeURIComponent(location.href)
      url    = "mailto:?subject=[Pantheon] " + question + "&amp;body=Learn more at " + encodeURIComponent(location.href)
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
      url    = "http://facebook.com/sharer/sharer.php?u=" + encodeURIComponent(location.href)
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
      url    = "http://www.twitter.com/intent/tweet?text=" + question + "&url=" + encodeURIComponent(location.href) + "&hashtags=Pantheon, culture"
      opts   = 'status=1' +
             ',width='  + width  +
             ',height=' + height +
             ',top='    + top    +
             ',left='   + left

      window.open url, 'twitter', opts
      false

    "click #download": (d) ->
      svg = $("svg")[0]
      serializer = new XMLSerializer()
      str = serializer.serializeToString(svg)
      canvas = document.querySelector("canvas")
      context = canvas.getContext("2d")
      # convert the canvas to an image
      canvg canvas, str,
        log: true
        # offsetY: 20 #need to resize the canvas properly
        ignoreClear: true
        # renderCallback: ->
        #   $("#canvas").attr("style", "display:none")
        #   img = canvas.toDataURL("image/png")
      
      # add text to the canvas
      text = $("#question").text()
      context.font = "bold 16px Lato"
      context.textAlign = "left"
      context.textBaseline = "top"
      context.fillStyle = "yellow"
      context.fillText text, 0, 0
      
      # add logo to the image
      base_image = new Image
      base_image.src = "/images/dark_theme_logo.png"
      base_image.onload = ->
        context.drawImage base_image, 0, 0
        
      $("#canvas").attr("style", "display:none")
      img = canvas.toDataURL("image/png")

      # write the picture to the webpage...
      # document.write "<img src=\"" + img + "\"/>"
      
      # download the picture as viz.png...
      a = document.createElement("a")
      a.download = "viz.png"
      a.href = img
      a.click()

# Template.spinner.rendered = ->
#   unless Session.get("showSpinner")
#     NProgress.configure
#       minimum: 0.2
#       trickleRate: 0.1
#       trickleSpeed: 500

#     NProgress.start()
#   Session.set "showSpinner", true

# Template.spinner.destroyed = ->
#   NProgress.done()
#   Session.set "showSpinner", false

# Template.sharing_options.events =
#   "click #download": (d) ->
#     svg = $("svg")[0]
#     serializer = new XMLSerializer()
#     str = serializer.serializeToString(svg)
#     canvas = document.querySelector("canvas")
#     context = canvas.getContext("2d")
#     image = new Image
#     canvg(canvas, str)
#     $("#canvas").attr("style", "display:none")
#     img = canvas.toDataURL("image/png")
#     # write the picture to the webpage...
#     # document.write "<img src=\"" + img + "\"/>"

#     url = "image/hello"
#     $.ajax(
#       type: "POST"
#       , url: url
#       , data: {imgBase64: img}
#       ).done((o) -> console.log "saved", url)
    
#     # download the picture as viz.png...
#     a = document.createElement("a")
#     a.download = "viz.png"
#     a.href = img
#     a.click()