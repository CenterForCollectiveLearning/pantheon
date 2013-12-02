treeProps =
  width: 700
  height: 560

Template.treemap_svg.properties = treeProps
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

Template.treemap_svg.rendered = ->
  
  # Don't re-render with the same parameters...?
  context = this
  viz = d3plus.viz()
  data = Treemap.find().fetch()

  attrs = {}
  vizMode = Session.get("vizMode")
  if vizMode is "country_exports" or vizMode is "country_imports" or vizMode is "bilateral_exporters_of"
    attr = Domains.find().fetch()
    attr.forEach (a) ->
      dom = a.domain.capitalize()
      ind = a.industry.capitalize()
      occ = a.occupation.capitalize()
      dom_color = color_domains(dom.toUpperCase())
      domDict =
        id: dom
        name: dom

      indDict =
        id: ind
        name: ind

      occDict =
        id: occ
        name: occ

      attrs[dom] =
        id: dom
        name: dom
        color: dom_color
        nesting_1: domDict

      attrs[ind] =
        id: ind
        name: ind
        color: dom_color
        nesting_1: domDict
        nesting_3: indDict

      attrs[occ] =
        id: occ
        name: occ
        color: dom_color
        nesting_1: domDict
        nesting_3: indDict
        nesting_5: occDict

    flat = []
    inner_html = (obj) -> #Change the below to update using the same from/to/L/dataset!
      category = Session.get("tooltipCategory")
      from = Session.get("from")
      to = Session.get("to")
      L = Session.get("langs")
      dataset = Session.get("dataset")
      params = "/all/" + [from, to, L, dataset].join("/")
      html = "<div>Who Exports " + category.capitalize() + "s? View in: <a href='/treemap/domain_exports_to/" + category + params + "'>Treemap</a>"
      html += " | " + "<a href='/map/map/" + category + params + "'>World Map</a>" + "</br>"
      html += "<a href='/histogram/domain_exports_to/" + category + params + "'> Who has comparative advantage in " + category.capitalize() +  "s?</a></div>"
      return html

    data.forEach (d) ->
      flat.push #use a dummy year here for now ...
        id: d.occupation.capitalize()
        name: d.occupation.capitalize()
        num_ppl: d.count
        year: 2000
    

    viz.type("tree_map")
      .tooltip_info({})
      # you cannot do this what is wrong withy  ou
      .width($(".page-middle").width())
      .height($(".page-middle").height())
      .id_var("id")
      .attrs(attrs)
      .text_var("name")
      .value_var("num_ppl")
      .total_bar(
        prefix: "Total Exports: "
        suffix: " individuals"
      )
      .nesting(["nesting_1", "nesting_3", "nesting_5"]).depth("nesting_5").font("Lato").font_weight("300").color_var("color").click_function(inner_html)
    # click_function - adding a click event for the treemaps
    # this is not rendered with a template here
    d3.select(context.find("svg")).datum(flat).call viz
  else if vizMode is "domain_exports_to"
    attr = Countries.find().fetch()
    attr.forEach (a) ->
      continent = a.continentName
      countryCode = a.countryCode
      countryName = a.countryName.capitalize()
      continent_color = color_countries(continent)
      continentDict =
        id: continent
        name: continent

      countryDict =
        id: countryCode
        name: countryName

      attrs[continent] =
        id: continent
        name: continent
        color: continent_color
        nesting_1: continentDict

      attrs[countryCode] =
        id: countryCode
        name: countryName
        color: continent_color
        nesting_1: continentDict
        nesting_3: countryDict

    flat = []
    inner_html = (obj) -> #Change the below to update using the same from/to/L/dataset!
      countryCode = Session.get("tooltipCountryCode")
      from = Session.get("from")
      to = Session.get("to")
      L = Session.get("langs")
      dataset = Session.get("dataset")
      params = "/all/" + [from, to, L, dataset].join("/")
      country = (Countries.findOne({countryCode: countryCode}).countryName).capitalize()
      html = "<div>Who are the cultural exports of " + country + "? View in: <a href='/treemap/country_exports/" + countryCode + params + "'>Treemap</a>"
      html += "</br><a href='/histogram/country_exports/" + countryCode + params + "'> What is the comparative advantage of " + country +  "?</a></div>"
      return html

    data.forEach (d) ->
      flat.push #use a dummy year here for now ...
        id: d.countryCode
        name: d.countryName.capitalize()
        num_ppl: d.count
        year: 2000

    viz.type("tree_map").tooltip_info({}).width($(".page-middle").width()).height($(".page-middle").height()).id_var("id").attrs(attrs).text_var("name").value_var("num_ppl").total_bar(
      prefix: "Total Exports: "
      suffix: " individuals"
    ).nesting(["nesting_1", "nesting_3"]).depth("nesting_3").font("Lato").font_weight("300").color_var("color").click_function(inner_html)
    d3.select(context.find("svg")).datum(flat).call viz
  else if vizMode is "domain_imports_from" or vizMode is "bilateral_importers_of"
    attr = Languages.find().fetch()
    attr.forEach (a) ->
      family = a.lang_family
      langCode = a.lang
      langName = a.lang_name
      family_color = color_languages(family)
      familyDict =
        id: family
        name: family

      langDict =
        id: langCode
        name: langName

      attrs[family] =
        id: family
        name: family
        color: family_color
        nesting_1: familyDict

      attrs[langCode] =
        id: langCode
        name: langName
        color: family_color
        nesting_1: familyDict
        nesting_3: langDict

    flat = []
    data.forEach (d) ->
      flat.push #use a dummy year here for now ...
        id: d.lang
        name: d.lang_name
        num_ppl: d.count
        year: 2000
    

    viz.type("tree_map")
        .tooltip_info({})
        .width($(".page-middle").width())
        .height($(".page-middle").height())
        .id_var("id")
        .attrs(attrs)
        .text_var("name")
        .value_var("num_ppl")
        .total_bar(
          prefix: "Total: "
          suffix: " Wikipedia Pages"
          )
        .nesting(["nesting_1", "nesting_3"])
        .depth("nesting_3")
        .font("Lato")
        .font_weight(400)
        .color_var("color")

    d3.select(context.find("svg"))
        .datum(flat)
        .call viz