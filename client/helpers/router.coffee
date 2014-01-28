# Almost all session changes happen here!
# I.e. session is used to record state

# splashCheck ->
#   (if Session.get("authorized") then page else "splash")

# Router.configure before: splashCheck

Router.map ->
  @route "home",
    path: "/"
    template: "home"
    data: -> 
      Session.set "page", @template

  @route "observatory",
    path: "/observatory"
    before: [ ->
      @redirect "/" + defaults.vizType + "/" + defaults.vizMode + "/" + defaults.country + "/" + defaults.language + "/" + defaults.from + "/" + defaults.to + "/" + defaults.langs + "/" + defaults.dataset
    ]

  @route "observatory",
    path: "/:vizType/:vizMode/:paramOne/:paramTwo/:from/:to/:langs/:dataset"
    data: ->
      vizMode = @params.vizMode
      Session.set "page", @template
      Session.set "vizType", @params.vizType
      Session.set "vizMode", @params.vizMode
      Session.set IOMapping[vizMode]["in"][0], @params.paramOne
      Session.set IOMapping[vizMode]["in"][1], @params.paramTwo
      Session.set "from", @params.from
      Session.set "to", @params.to
      Session.set "langs", @params.langs
      if @params.langs[0] is "H" then Session.set "indexType", "HPI" else Session.set "indexType", "L"
      Session.set "dataset", @params.dataset

      # Reset defaults based on vizmode
      if vizMode is "country_exports"
        Session.set "category", defaults.category
      else if vizMode is "domain_exports_to"
        Session.set "country", defaults.country
      else if vizMode is "country_vs_country"
        Session.set "country", defaults.country
        Session.set "category", defaults.category
        Session.set "categoryLevel", defaults.categoryLevel
      else if vizMode is "domain_vs_domain"
        Session.set "category", defaults.category

      # Set category level based on category parameters
      if IOMapping[vizMode]["in"][0] is "category" or IOMapping[vizMode]["in"][0] is "categoryX" or IOMapping[vizMode]["in"][0] is "categoryY"
        Session.set "categoryLevel", getCategoryLevel(@params.paramOne)  
      if IOMapping[vizMode]["in"][1] is "category" or IOMapping[vizMode]["in"][1] is "categoryX" or IOMapping[vizMode]["in"][1] is "categoryY"
        Session.set "categoryLevel", getCategoryLevel(@params.paramTwo)  

  @route "vision",
    data: ->
      Session.set "page", @template

  @route "rankings",
    path: "/rankings"
    before: [->
      @redirect "/rankings/" + defaults.entity + "/all/" + defaults.category + "/" + defaults.from + "/" + defaults.to + "/" + defaults.langs
    ]

  @route "rankings",
    path: "/rankings/:entity/:country/:category/:from/:to/:langs"
    data: ->
      Session.set "page", @template
      Session.set "entity", @params.entity
      Session.set "country", @params.country
      Session.set "category", @params.category
      Session.set "from", @params.from
      Session.set "to", @params.to
      Session.set "langs", @params.langs  
      Session.set "dataset", "OGC"
      if @params.langs[0] is "H" then Session.set "indexType", "HPI" else Session.set "indexType", "L" 

  @route "data",
    path: "/data"
    data: ->
      Session.set "page", @template
    action: ->
      @render()
    after: ->
      hash = @params.hash
      id = "#" + hash
      Session.set("pageScrollID", id)

  @route "faq",
    data: ->
      Session.set "page", @template

  @route "references",
    data: ->
      Session.set "page", @template

  @route "people",
    path: "/people"
    before: [->
      @redirect "/people/" + defaults.person
    ]

  @route "people",
    path: "/people/:name"
    waitOn: -> Meteor.subscribe("allpeople")
    data: ->
      Session.set "page", @template
      Session.set "name", @params.name

  @route "team",
    data: ->
      Session.set "page", @template
  
  @route "notFound",
    path: "*"

  @route "saveImage",
    where: "server"
    path: "/image/:imagename"
    action: ->
      imagename = @params.imagename
      console.log "IN ROUTER, imagename:", imagename
      @response.writeHead(200, {'Content-Type': 'text/html'});
      @response.end('hello from server');

Router.configure
  layoutTemplate: "defaultLayout"
  yieldTemplates:
    nav:
      to: "nav"
    footer:
      to: "footer"

