# Color keys for domains, countries, and languages (if needed)
# Green, red, brown, yellow, beige, pink, blue, orange
color_domains = d3.scale.ordinal()
  .domain(["INSTITUTIONS", "ARTS", "HUMANITIES", "BUSINESS & LAW", "EXPLORATION", "PUBLIC FIGURE", "SCIENCE & TECHNOLOGY", "SPORTS"])
  .range(["#468966", "#8e2800", "#864926", "#ffb038", "#fff0a5", "#bc4d96", "#1be6ef", "#ff5800"])
color_languages = d3.scale.ordinal()
  .domain(["Afro-Asiatic", "Altaic", "Austro-Asiatic", "Austronesian", "Basque", "Caucasian", "Creoles and pidgins", "Dravidian", "Eskimo-Aleut", "Indo-European", "Niger-Kordofanian", "North American Indian", "Sino-Tibetan", "South American Indian", "Tai", "Uralic"])
  .range(["#E0BA9B", "#D95B43", "#43c1d9", "#C02942", "#546c97", "#d278c2", "#53a9f1", "#79BD9A", "#A69E80", "#ECD078", "#D28574", "#E7EDEA", "#CEECEF", "#912D1D", "#DE7838", "#59AB6D"])
color_countries = d3.scale.ordinal()
  .domain(["Africa", "Asia", "Europe", "North America", "South America", "Oceania"])
  .range(["#E0BA9B", "#D95B43", "#43c1d9", "#C02942", "#546c97", "#d278c2"])

chartProps =
  width: 700
  height: 560

Template.stacked_svg.properties = chartProps

Template.stacked_svg.rendered = ->
  console.log("rendering STACKED AREA CHART") #This is getting rendered 3x!!
  context = this
  attrs = {}
  vizMode = Session.get("vizMode")
  data = Stacked.find().fetch()

  if vizMode is "country_exports" #http://localhost:3000/stacked/country_exports/US/all/1980/1990/25
    domains = Domains.find().fetch()
    domains.forEach (d) ->
      domDict =
        domain: d.domain
        color: color_domains(d.domain)
      attrs[d.occupation] = d
      attrs[d.occupation].color = color_domains(d.domain)
      attrs[d.domain] = domDict

  #  console.log("ATTRS:DOMAINS")
  #  console.log(attrs)
  #  console.log("DATA:STACKED")
  #  console.log(data)

    viz = d3plus.viz()
    .type("stacked")
    .id_var("occupation")
    .attrs(attrs)
    .text_var("occupation")
    .value_var("count")
    .tooltip_info(["occupation", "industry", "domain", "count", "year"])
    .nesting(["domain", "occupation"])
    .depth("domain")
    .xaxis_var("year")
    .year_var("year")
    .font("Helvetica Neue")
    .font_weight("lighter")
  #          .title("Test")
    .stack_type("monotone")
    .layout("value")
    .width($(".page-middle").width())
    .height("564")
    .color_var("color")

    d3.select("#viz")
    .datum(data)
    .call(viz)

  else if vizMode is "domain_exports_to" # http://localhost:3000/stacked/domain_exports_to/all/all/1900/1950/25/
    console.log("domain_exports_to")
    countries = Countries.find().fetch()
    countries.forEach (c) ->
      continentDict =
        continentName: c.continentName
        color: color_countries(c.continentName)
      attrs[c.countryCode] = c
      attrs[c.countryCode].color = color_countries(c.continentName)
      attrs[c.continentName] = continentDict

    console.log("ATTRS:COUNTRIES")
    console.log(attrs)
    console.log("DATA:STACKED")
    console.log(data)

    viz = d3plus.viz()
    .type("stacked")
    .id_var("countryCode")
    .attrs(attrs)
    .text_var("countryCode")
    .value_var("count")
    .nesting(["continentName", "countryCode"])
    .depth("countryCode")
    .xaxis_var("year")
    .year_var("year")
    .font("Helvetica Neue")
    .font_weight("lighter")
    #          .title("Test")
    .stack_type("monotone")
    .layout("value")
    .width($(".page-middle").width())
    .height("564")
    .color_var("color")

    d3.select("#viz")
    .datum(data)
    .call(viz)

