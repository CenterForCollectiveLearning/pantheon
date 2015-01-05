# Almost all session changes happen here!
# I.e. session is used to record state

Router.map ->
  # @route "home",
  #   path: "/"
  #   template: "home"
  #   data: -> 
  #     Session.set "page", @template

  @route "home",
    path: "/"
    template: "visualizations"
    before: [ ->
      @redirect "/viz"
    ]

  @route "embed",
    path: "/embed/:vizType/:vizMode/:paramOne/:paramTwo/:from/:to/:langs/:dataset"
    layoutTemplate: "embeddable"
    yieldTemplates: {}
    data: ->
      vizMode = @params.vizMode
      Session.set "page", "visualizations"
      Session.set "vizType", @params.vizType
      Session.set "vizMode", @params.vizMode
      Session.set IOMapping[vizMode]["in"][0], @params.paramOne
      Session.set IOMapping[vizMode]["in"][1], @params.paramTwo
      Session.set "from", @params.from
      Session.set "to", @params.to
      Session.set "langs", @params.langs
      if @params.langs[0] is "H" then Session.set "indexType", "HPI" else Session.set "indexType", "L"
      if @params.dataset is "murray" then Session.set "dataset", @params.dataset else if @params.dataset is "pantheon" then Session.set "dataset", "OGC"


  @route "viz",
    path: "/viz"
    template: "visualizations"
    before: [ ->
      @redirect "/" + defaults.vizType + "/" + defaults.vizMode + "/" + defaults.country + "/" + defaults.language + "/" + defaults.from + "/" + defaults.to + "/" + defaults.langs + "/pantheon"
    ]

  @route "viz",
    path: "/:vizType/:vizMode/:paramOne/:paramTwo/:from/:to/:langs/:dataset"
    template: "visualizations"
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
      if @params.dataset is "murray" then Session.set "dataset", @params.dataset else if @params.dataset is "pantheon" then Session.set "dataset", "OGC"

      # Reset defaults based on vizmode
      if vizMode is "country_exports"
        Session.set "category", "all"
      else if vizMode is "domain_exports_to"
        Session.set "country", "all"
      else if vizMode is "country_vs_country"
        Session.set "country", defaults.country
        Session.set "category", "all"
        Session.set "categoryLevel", defaults.categoryLevel
      else if vizMode is "domain_vs_domain"
        Session.set "category", "all"
      else if vizMode is "matrix_exports"
        Session.set "country", "all"
        Session.set "category", "all"
        Session.set "categoryLevel", defaults.categoryLevel
      else if vizMode is "map"
        Session.set "country", "all"

      # TODO Rethink this pipeline
      # Set category level based on category parameters
      if IOMapping[vizMode]["in"][0] is "category" or IOMapping[vizMode]["in"][0] is "categoryX" or IOMapping[vizMode]["in"][0] is "categoryY"
        Session.set "categoryLevel", getCategoryLevel(@params.paramOne)  
        Session.set "categoryLevelX", getCategoryLevel(@params.paramOne)  
      if IOMapping[vizMode]["in"][1] is "category" or IOMapping[vizMode]["in"][1] is "categoryX" or IOMapping[vizMode]["in"][1] is "categoryY"
        Session.set "categoryLevel", getCategoryLevel(@params.paramTwo)  
        Session.set "categoryLevelY", getCategoryLevel(@params.paramTwo)  

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
      Session.set "categoryLevel", getCategoryLevel(@params.category)  
      Session.set "from", @params.from
      Session.set "to", @params.to
      Session.set "langs", @params.langs  
      Session.set "clicktooltip", false  
      Session.set "dataset", "OGC"
      # Session.set "vizMode", "domain_exports_to"
      if @params.langs[0] is "H" then Session.set "indexType", "HPI" else Session.set "indexType", "L" 

  @route "methods",
    path: "/methods"
    data: ->
      Session.set "page", @template
    action: ->
      @render()
    after: ->
      hash = @params.hash
      id = "#" + hash
      Session.set("pageScrollID", id)

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

