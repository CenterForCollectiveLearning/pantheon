# Almost all session changes happen here!
# I.e. session is used to record state

setVizModeParams = (params) ->
  vizMode = params.vizMode
  Session.set "vizType", params.vizType
  Session.set "vizMode", params.vizMode
  Session.set IOMapping[vizMode]["in"][0], params.paramOne
  Session.set IOMapping[vizMode]["in"][1], params.paramTwo
  Session.set "from", params.from
  Session.set "to", params.to
  Session.set "langs", params.langs
  if params.langs[0] is "H" then Session.set "indexType", "HPI" else Session.set "indexType", "L"
  if params.dataset is "murray" then Session.set "dataset", params.dataset else if params.dataset is "pantheon" then Session.set "dataset", "OGC"

  # Reset defaults based on vizmode
  switch vizMode
    when "country_exports", "country_by_city"
      Session.set "category", "all"
    when "domain_exports_to", "domain_exports_to_city"
      Session.set "country", "all"
    when "country_vs_country"
      Session.set "country", defaults.country
      Session.set "category", "all"
      Session.set "categoryLevel", defaults.categoryLevel
    when "domain_vs_domain"
      Session.set "category", "all"
    when "matrix_exports"
      Session.set "country", "all"
      Session.set "category", "all"
      Session.set "categoryLevel", defaults.categoryLevel
    when "map"
      Session.set "country", "all"

  # TODO Rethink this pipeline
  # Set category level based on category parameters
  if IOMapping[vizMode]["in"][0] is "category" or IOMapping[vizMode]["in"][0] is "categoryX" or IOMapping[vizMode]["in"][0] is "categoryY"
    Session.set "categoryLevel", getCategoryLevel(params.paramOne)  
    Session.set "categoryLevelX", getCategoryLevel(params.paramOne)  
  if IOMapping[vizMode]["in"][1] is "category" or IOMapping[vizMode]["in"][1] is "categoryX" or IOMapping[vizMode]["in"][1] is "categoryY"
    Session.set "categoryLevel", getCategoryLevel(params.paramTwo)  
    Session.set "categoryLevelY", getCategoryLevel(params.paramTwo)  

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
    path: "/:vizType/:vizMode/:paramOne/:paramTwo/:from/:to/:langs/:dataset/embed"
    layoutTemplate: "embeddable"
    yieldTemplates: {}
    data: ->
      Session.set "embed", true
      Session.set "page", "visualizations"
      setVizModeParams(@params)

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
      Session.set "embed", false
      Session.set "page", @template
      setVizModeParams(@params)

  @route "api",
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

  @route "about",
    path: "/about"
    before: [ ->
      @redirect "/about/team"
    ]

  @route "about",
    path: "/about/:section"
    data: ->
      Session.set "page", @template
      Session.set "aboutsection", @params.section
    action: ->
      @render()
    after: ->
      hash = @params.hash
      if hash then id = "#" + hash else id = "#" + @params.section
      Session.set("pageScrollID", id)
  
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

