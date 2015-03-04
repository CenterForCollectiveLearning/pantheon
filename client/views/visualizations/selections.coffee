getCategoryLevel = (s) ->
  domains = Domains.find({dataset: Session.get("dataset")}).fetch()
  for i of domains
    domain_obj = domains[i]
    return "domain" if domain_obj.domain is s
    return "industry" if domain_obj.industry is s
    return "occupation" if domain_obj.occupation is s

Template.select_mode.render_template = ->
  page = Session.get("page")
  if page is "visualizations"
    type = Session.get("vizType")
    mode = Session.get("vizMode")
    switch mode
      when "country_exports"
        if type is "treemap"
          return new Handlebars.SafeString(Template.country_exporters_mode(this))
        else if type is "histogram"
          return new Handlebars.SafeString(Template.histogram_country_exporters_mode(this))
      when "country_imports"
        return new Handlebars.SafeString(Template.country_importers_mode(this))
      when "domain_exports_to"
        if type is "treemap"
          return new Handlebars.SafeString(Template.domain_mode(this))
        else if type is "histogram"
          return new Handlebars.SafeString(Template.histogram_domain_mode(this))
      when "domain_imports_from"
        return new Handlebars.SafeString(Template.domain_mode(this))
      when "bilateral_exporters_of"
        return new Handlebars.SafeString(Template.bilateral_exporters_mode(this))
      when "bilateral_importers_of"
        return new Handlebars.SafeString(Template.bilateral_importers_mode(this))
      when "matrix_exports"
        return new Handlebars.SafeString(Template.matrix_exports_mode(this))
      when "country_vs_country"
        return new Handlebars.SafeString(Template.country_vs_country_mode(this))
      when "lang_vs_lang"
        return new Handlebars.SafeString(Template.language_vs_language_mode(this))
      when "domain_vs_domain"
        return new Handlebars.SafeString(Template.domain_vs_domain_mode(this))
      when "map"
        return new Handlebars.SafeString(Template.map_mode(this))
  else if page is "rankings"
    entity = Session.get("entity")
    switch entity
      when "countries"
        return new Handlebars.SafeString(Template.countries_ranking_mode(this))
      when "people"
        return new Handlebars.SafeString(Template.people_ranking_mode(this))      
      when "domains"
        return new Handlebars.SafeString(Template.domains_ranking_mode(this))

Template.select_country.rendered = ->
  country = Session.get("country").split("+")
  countryCode = country[country.length-1]
  $(@find("select")).val(countryCode).chosen().change( ->
    path = window.location.pathname.split("/")
    countryCode = $(this).val()
    if IOMapping[Session.get("vizMode")]["in"].indexOf("country") is 0 then path[3] = countryCode
    else path[4] = countryCode
    Router.go path.join("/"))

Template.select_city.rendered = ->
  country = Session.get("country").split("+")
  if country.length > 1 then city = country[0] else city = "all"
  countryCode = country[country.length-1]
  $(@find("select")).val(city).chosen().change( ->
    path = window.location.pathname.split("/")
    location = $(this).val() 
    if location == "all"
      location = countryCode
    else
      location = location + "+" + countryCode
    if IOMapping[Session.get("vizMode")]["in"].indexOf("country") is 0 then path[3] = location
    else path[4] = countryCode
    Router.go path.join("/"))

Template.select_countryX.rendered = ->
  $(@find("select")).val(Session.get("countryX")).chosen().change( ->
    path = window.location.pathname.split("/")
    path[3] = $(this).val()
    Router.go path.join("/"))

Template.select_countryY.rendered = ->
  $(@find("select")).val(Session.get("countryY")).chosen().change( ->
    path = window.location.pathname.split("/")
    path[4] = $(this).val()
    Router.go path.join("/"))

Template.select_language.rendered = ->
  $(@find("select")).val(Session.get("language")).chosen().change( ->
    path = window.location.pathname.split("/")
    language = $(this).val()
    if IOMapping[Session.get("vizMode")]["in"].indexOf("language") is 0 then path[3] = language
    else path[4] = language
    Router.go path.join("/"))

Template.select_languageX.rendered = ->
  $(@find("select")).val(Session.get("languageX")).chosen().change( ->
    path = window.location.pathname.split("/")
    path[3] = $(this).val()
    Router.go path.join("/"))

Template.select_languageY.rendered = ->
  $(@find("select")).val(Session.get("languageY")).chosen().change( ->
    path = window.location.pathname.split("/")
    path[3] = $(this).val()
    Router.go path.join("/"))

Template.select_category.rendered = ->
  $(@find("select")).val(Session.get("category")).chosen().change( ->
    path = window.location.pathname.split("/")
    category = $(this).val()
    Session.set "categoryLevel", getCategoryLevel(category)
    if IOMapping[Session.get("vizMode")]["in"].indexOf("category") is 0 then path[3] = category
    else path[4] = category
    Router.go path.join("/"))

Template.select_categoryX.rendered = ->
  $(@find("select")).val(Session.get("categoryX")).chosen().change( ->
    path = window.location.pathname.split("/")
    category = $(this).val()
    Session.set "categoryLevel", getCategoryLevel(category)
    path[3] = category
    Router.go path.join("/"))

Template.select_categoryY.rendered = ->
  $(@find("select")).val(Session.get("categoryY")).chosen().change( ->
    path = window.location.pathname.split("/")
    category = $(this).val()
    path[4] = category
    Router.go path.join("/"))

Template.select_from.rendered = ->
  select = $(@find("select"))
  select.val(Session.get("from")).chosen().change( ->
    path = window.location.pathname.split("/")
    path[5] = $(this).val()
    Router.go path.join("/"))

Template.select_to.rendered = ->
  $(@find("select")).val(Session.get("to")).chosen().change( ->
    path = window.location.pathname.split("/")
    path[6] = $(this).val()
    Router.go path.join("/"))

Template.select_entity.rendered = ->
  $(@find("select")).val(Session.get("entity")).chosen().change( ->
    path = window.location.pathname.split("/")
    path[2] = $(this).val()
    Router.go path.join("/"))

Template.select_l.rendered = ->
  $(@find("select")).val(Session.get("langs")).chosen().change( ->
    path = window.location.pathname.split("/")
    L = $(this).val()
    if L[0] is "H" 
      Session.set "indexType", "H" 
    else if Session.equals("dataset", "OGC") 
      Session.set "indexType", "L"
    path[7] = L
    Router.go path.join("/"))

Template.select_l.murray = -> Session.equals("dataset", "murray")
Template.select_l.HPI = -> Session.equals("indexType", "HPI")   

Template.select_l.L_active = -> if Session.equals("indexType", "L") then "active" else ""
Template.select_l.HPI_active = -> if Session.equals("indexType", "HPI") then "active" else ""

Template.select_l.events = 
  "click #L-button": (d) -> 
    path = window.location.pathname.split("/")
    path[7] = "25"
    Router.go path.join("/")
  "click #HPI-button": (d) -> 
    path = window.location.pathname.split("/")
    path[7] = "H15"
    Router.go path.join("/")   

Template.select_gender.female_active = -> if Session.equals("gender", "female") then "active" else ""
Template.select_gender.male_active = -> if Session.equals("gender", "male") then "active" else ""
Template.select_gender.ratio_active = -> if Session.equals("gender", "ratio") then "active" else ""
Template.select_gender.both_active = -> if Session.equals("gender", "both") then "active" else ""


Template.select_gender.events = # TODO: For now, we're assuming that only matrices have gender enabled
  "click #both-button": (d) -> 
    path = window.location.pathname.split("/")
    path[4] = "both"
    Router.go path.join("/")
  "click #male-button": (d) -> 
    path = window.location.pathname.split("/")
    path[4] = "male"
    Router.go path.join("/")
  "click #female-button": (d) -> 
    path = window.location.pathname.split("/")
    path[4] = "female"
    Router.go path.join("/")
  "click #ratio-button": (d) -> 
    path = window.location.pathname.split("/")
    path[4] = "ratio"
    Router.go path.join("/")


Template.select_country_order.events = 
  "click div.button": (d) ->
    srcE = (if d.srcElement then d.srcElement else d.target)
    $(srcE).addClass("active")

    targetID = $(srcE)[0].id
    if targetID is "country-count-button"
      $("#country-name-button").removeClass("active")
      order = "count"
    else if targetID is "country-name-button"
      $("#country-count-button").removeClass("active")
      order = "name"
    Session.set "countryOrder", order

Template.select_industry_order.events = 
  "click div.button": (d) ->
    srcE = (if d.srcElement then d.srcElement else d.target)
    $(srcE).addClass("active")

    targetID = $(srcE)[0].id
    if targetID is "industry-count-button"
      $("#industry-name-button").removeClass("active")
      order = "count"
    else if targetID is "industry-name-button"
      $("#industry-count-button").removeClass("active")
      order = "name"
    Session.set "industryOrder", order

Template.select_industry_order.rendered = ->
  $(@find("select")).val(Session.get("industryOrder")).chosen().change( ->
    Session.set "industryOrder", $(this).val())

Template.select_dataset.rendered = ->
  $(@find("select")).val(Session.get("dataset")).chosen().change( ->
    dataset = $(this).val()
    vizMode = Session.get("vizMode")
    path = window.location.pathname.split("/")
    path[7] = path[7].toString()
    # make sure transitions between datasets are smooth
    # if linked entities exist between the two datasets, use the existing selections. otherwise create a randomized view with valid parameters.
    if dataset is "murray"
      path[7] = 0 # set the default index value for murray data
      # treemap by country
      if (vizMode is 'country_exports') and (Countries.find({dataset:dataset, countryCode: Session.get("country")}).count() is 0)
        countryCode = getRandomFromArray(murrayCountries) 
        path[3] = countryCode
      # treemap by domain, map
      if vizMode in ["domain_exports_to","map"]
        domain = Session.get 'category'
        newdomain = mpdomains[domain]
        if(newdomain) then path[3] = newdomain
        else path[3] = getRandomFromArray(_.values(mpdomains))
      # country v country scatterplot
      if vizMode is 'country_vs_country' and ((Countries.find({dataset:dataset, countryCode: Session.get("countryX")}).count() is 0) or (Countries.find({dataset:dataset, countryCode: Session.get("countryY")}).count() is 0))
        countryX = getRandomFromArray(murrayCountries)
        countryY = getRandomFromArray(murrayCountries)
        while countryX is countryY
          countryY = getRandomFromArray(murrayCountries)
        path[3] = countryX
        path[4] = countryY
      # domain v domain scatterplot
      if vizMode is 'domain_vs_domain' 
        if mpdomains[Session.get("categoryX")]? and mpdomains[Session.get("categoryY")]?
          categoryX = mpdomains[Session.get("categoryX")]
          categoryY = mpdomains[Session.get("categoryY")]
        else
          categoryX = getRandomFromArray(_.values(mpdomains))
          categoryY = getRandomFromArray(_.values(mpdomains))
          while categoryX is categoryY
            categoryY = getRandomFromArray(_.values(mpdomains))
        path[3] = categoryX
        path[4] = categoryY
      else 
    if dataset is "OGC"
      path[7] = 'H15' # set the default index value for Pantheon data
      # treemap by country
      if (vizMode is 'country_exports') and (Countries.find({dataset:dataset, countryCode: Session.get("country")}).count() is 0)
        countryCode = getRandomFromArray(pantheonCountries)
        path[3] = countryCode
      # treemap by domain and maps
      if vizMode in ["domain_exports_to","map"]
        domain = Session.get 'category'
        newdomain = (_.invert(mpdomains))[domain]
        if(newdomain) then path[3] = newdomain
        else path[3] = getRandomFromArray(_.keys(mpdomains))
      # country v country scatterplot
      if vizMode is 'country_vs_country' and ((Countries.find({dataset:dataset, countryCode: Session.get("countryX")}).count() is 0) or (Countries.find({dataset:dataset, countryCode: Session.get("countryY")}).count() is 0))
        countryX = getRandomFromArray(pantheonCountries)
        countryY = getRandomFromArray(pantheonCountries)
        while countryX is countryY
          countryY = getRandomFromArray(pantheonCountries)
        path[3] = countryX
        path[4] = countryY
      # domain v domain scatterplot
      if vizMode is 'domain_vs_domain' 
        if (_.invert(mpdomains))[Session.get("categoryX")]? and (_.invert(mpdomains))[Session.get("categoryY")]?
          categoryX = (_.invert(mpdomains))[Session.get("categoryX")]
          categoryY = (_.invert(mpdomains))[Session.get("categoryY")]
        else
          categoryX = getRandomFromArray(_.keys(mpdomains))
          categoryY = getRandomFromArray(_.keys(mpdomains))
          while categoryX is categoryY
            categoryY = getRandomFromArray(_.keys(mpdomains))
        path[3] = categoryX
        path[4] = categoryY
    path[8] = if dataset is "murray" then dataset else if dataset is "OGC" then "pantheon"
    Router.go path.join("/"))

Template.select_scale.events =
  "click div.button": (d) ->
    srcE = (if d.srcElement then d.srcElement else d.target)
    $(srcE).addClass("active")

    targetID = $(srcE)[0].id
    if targetID is "linear-button"
      $("#log-button").removeClass("active")
      scaleType = "linear"
    else if targetID is "log-button"
      $("#linear-button").removeClass("active")
      scaleType = "log"
    Session.set "scatterplotScale", scaleType

Template.select_mirror.events =
  "click div.button": (d) ->
    srcE = (if d.srcElement then d.srcElement else d.target)
    $(srcE).addClass("active")

    targetID = $(srcE)[0].id
    if targetID is "mirror-true-button"
      $("#mirror-false-button").removeClass("active")
      mirrorType = true
    else if targetID is "mirror-false-button"
      $("#mirror-true-button").removeClass("active")
      mirrorType = false
    Session.set "scatterplotMirror", mirrorType


Template.country_dropdown.countries = ->
  dataset = Session.get("dataset")
  murray_countries = []
  data = Countries.find {dataset: dataset, countryCode: {$ne:"UNK"}},
    sort:
      countryName: 1
  grouped = _.groupBy data.fetch(), (d) ->
    d.countryCode
  if dataset is "murray"
    for k,v of grouped
      country = {}
      country.countryCode = k
      country.countryName = v[0].countryName
      murray_countries.push country
    return murray_countries
  else
    return data

Template.city_dropdown.cities_given_country = ->
  uniqueCities = []
  res = []
  country = Session.get("country").split("+")
  countryCode = country[country.length-1]
  _.each ClientPeople.find(countryCode: countryCode, dataset: Session.get("dataset")).fetch(), (country_obj) ->
    birthcity = country_obj.birthcity
    if uniqueCities.indexOf(birthcity) is -1
      uniqueCities.push birthcity
      res.push birthcity: $.trim(birthcity)
  _.sortBy(res, 'birthcity')

Template.language_dropdown.languages = ->
  Languages.find {},
    sort:
      lang_name: 1


Template.category_dropdown.domains = ->
  uniqueDomains = []
  res = []
  _.each Domains.find({dataset: Session.get("dataset")}).fetch(), (domain_obj) ->
    domain = domain_obj.domain
    if uniqueDomains.indexOf(domain) is -1
      uniqueDomains.push domain
      res.push domain: domain
  res

Template.category_dropdown_only_domain.domains = ->
  uniqueDomains = []
  res = []
  _.each Domains.find({dataset: Session.get("dataset")}).fetch(), (domain_obj) ->
    domain = domain_obj.domain
    if uniqueDomains.indexOf(domain) is -1
      uniqueDomains.push domain
      res.push domain: domain
  res

Template.category_dropdown.industries = ->
  uniqueIndustries = []
  res = []
  _.each Domains.find({dataset: Session.get("dataset")}).fetch(), (domain_obj) ->
    industry = domain_obj.industry
    if uniqueIndustries.indexOf(industry) is -1
      uniqueIndustries.push industry
      res.push industry: industry

  res

Template.industry_item.occupations_given_industry = ->
  uniqueOccupations = []
  res = []
  _.each Domains.find(industry: @industry, dataset: Session.get("dataset")).fetch(), (domain_obj) ->
    occupation = domain_obj.occupation
    if uniqueOccupations.indexOf(occupation) is -1
      uniqueOccupations.push occupation
      res.push occupation: occupation

  res

Template.domain_item.industries_given_domain = ->
  uniqueIndustries = []
  res = []
  _.each Domains.find(domain: @domain, dataset: Session.get("dataset")).fetch(), (domain_obj) ->
    industry = domain_obj.industry
    if uniqueIndustries.indexOf(industry) is -1
      uniqueIndustries.push industry
      res.push industry: industry

  res

# Declare a helper to capitalize the domain names in the UI 
Handlebars.registerHelper "capitalize", (str) ->
  str.capitalize()
