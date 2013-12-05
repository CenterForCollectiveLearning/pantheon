
# selections for Observatory (visualizations)

# Change selected based on session variables
# The below code also sets uniform on each element individually
# Setting them at a parent template will cause the errors we saw before
# This is equivalent to $(item).val(blah)
#                       $(item).uniform()
#

# $(this.find("select")).val(Session.get("country")).chosen({width: "60%"});

# TODO: Find closest round number

# TODO: Do this correctly and reduce redundancy
# TODO: How do you get this tracking correctly?

# My idea:
#   If you're going to do it this way, don't copy the same code 9 times :)
#    However, the way I would do it is to cut the current value out of the right part of the route (as an integer index)
#     and then just update the router to the new route. This will set session variables as a side effect.
#
#    Your current approach is going to be setting session variables twice.
# 
getCategoryLevel = (s) ->
  domains = Domains.find({dataset: Session.get("dataset")}).fetch()
  for i of domains
    domain_obj = domains[i]
    return "domain"  if domain_obj.domain is s
    return "industry"  if domain_obj.industry is s
    return "occupation"  if domain_obj.occupation is s
Template.select_mode.render_template = ->
  page = Session.get("page")
  if page is "observatory"
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

Template.select_country.rendered = ->
  $(@find("select")).val(Session.get("country")).chosen().change( ->
    path = window.location.pathname.split("/")
    countryCode = $(this).val()
    if IOMapping[Session.get("vizMode")]["in"].indexOf("country") is 0 then path[3] = countryCode
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
  $(@find("select")).val(Session.get("from")).chosen().change( ->
    path = window.location.pathname.split("/")
    path[5] = $(this).val()
    Router.go path.join("/"))

Template.select_to.rendered = ->
  $(@find("select")).val(Session.get("to")).chosen().change( ->
    path = window.location.pathname.split("/")
    path[6] = $(this).val()
    Router.go path.join("/"))

Template.select_l.rendered = ->
  $(@find("select")).val(Session.get("langs")).chosen().change( ->
    path = window.location.pathname.split("/")
    path[7] = $(this).val()
    Router.go path.join("/"))

Template.select_gender.rendered = ->
  $(@find("select")).val(Session.get("gender")).chosen().change( ->
    Session.set "gender", $(this).val())

Template.select_country_order.rendered = ->
  $(@find("select")).val(Session.get("countryOrder")).chosen().change( ->
    Session.set "countryOrder", $(this).val())

Template.select_industry_order.rendered = ->
  $(@find("select")).val(Session.get("industryOrder")).chosen().change( ->
    Session.set "industryOrder", $(this).val())

Template.select_dataset.rendered = ->
  $(@find("select")).val(Session.get("dataset")).chosen().change( ->
    dataset = $(this).val()
    Session.set "dataset", dataset
    path = window.location.pathname.split("/")
    path[8] = dataset
    Router.go path.join("/"))

Template.country_dropdown.countries = ->
  Countries.find {dataset: Session.get("dataset")},
    sort:
      countryName: 1


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
  _.each Domains.find(industry: @industry).fetch(), (domain_obj) ->
    occupation = domain_obj.occupation
    if uniqueOccupations.indexOf(occupation) is -1
      uniqueOccupations.push occupation
      res.push occupation: occupation

  res

Template.domain_item.industries_given_domain = ->
  uniqueIndustries = []
  res = []
  _.each Domains.find(domain: @domain).fetch(), (domain_obj) ->
    industry = domain_obj.industry
    if uniqueIndustries.indexOf(industry) is -1
      uniqueIndustries.push industry
      res.push industry: industry

  res