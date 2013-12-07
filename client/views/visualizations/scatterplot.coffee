# TODO Namespace these
scatterplotProps =
  width: 725
  height: 560

Template.scatterplot_svg.properties = scatterplotProps
color_domains = d3.scale.ordinal().domain(["INSTITUTIONS", "ARTS", "HUMANITIES", "BUSINESS & LAW", "EXPLORATION", "PUBLIC FIGURE", "SCIENCE & TECHNOLOGY", "SPORTS"]).range(["#ECD078", "#D95B43", "#43c1d9", "#C02942", "#546c97", "#d278c2", "#53a9f1", "#79BD9A"])
color_countries = d3.scale.ordinal().domain(["Africa", "Asia", "Europe", "North America", "South America", "Oceania"]).range(["#E0BA9B", "#D95B43", "#43c1d9", "#C02942", "#546c97", "#d278c2"])
Template.scatterplot_svg.rendered = ->
  context = this
  
  # if( this.rendered ) return;
  # this.rendered = true;
  viz = d3plus.viz()
  vizMode = Session.get("vizMode")
  if vizMode is "country_vs_country"
    field = "countryCode"
    x_code = Session.get("countryX")
    y_code = Session.get("countryY")
    x_name = Countries.findOne(countryCode: x_code).countryName
    y_name = Countries.findOne(countryCode: y_code).countryName
    aggregatedField = "occupation"
    nesting = ["nesting_1", "nesting_3", "nesting_5"]
    nestingDepth = "nesting_3"
  else if vizMode is "lang_vs_lang"
    field = "lang"
    x_code = Session.get("languageX")
    y_code = Session.get("languageY")
    x_name = Languages.findOne(lang: x_code).lang_name
    y_name = Languages.findOne(lang: y_code).lang_name
    aggregatedField = "occupation"
    nesting = ["nesting_1", "nesting_3", "nesting_5"]
    nestingDepth = "nesting_3"
  else if vizMode is "domain_vs_domain"
    field = "domain"
    x_code = Session.get("categoryX")
    y_code = Session.get("categoryY")
    x_name = x_code
    y_name = y_code
    aggregatedField = "countryName"
    nesting = ["nesting_1", "nesting_3"]
    nestingDepth = "nesting_3"
  data = Scatterplot.find().fetch()
  aggregated = {} # X, Y values for each data point (eg. {WRITER: {x:1, y:5}})
  flatData = [] # Array of objects {xname: 130, yname:87, id: PHYSICIST}
  attrs = {}
  if vizMode is "country_vs_country" or vizMode is "lang_vs_lang"
    attr = Domains.find().fetch()
    attr.forEach (a) ->
      dom = a.domain
      ind = a.industry
      occ = a.occupation
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

  else if vizMode is "domain_vs_domain"
    attr = Countries.find().fetch()
    attr.forEach (a) ->
      continent = a.continentName
      countryCode = a.countryCode
      countryName = a.countryName
      continent_color = color_countries(continent)
      continentDict =
        id: continent
        name: continent

      countryDict =
        id: countryName
        name: countryName

      attrs[continent] =
        id: continent
        name: continent
        color: continent_color
        nesting_1: continentDict

      attrs[countryName] =
        id: countryName
        name: countryName
        color: continent_color
        nesting_1: continentDict
        nesting_3: countryDict

  
  # AGGREGATE
  for i of data
    datum = data[i]
    dataPoint = datum[aggregatedField]
    count = datum.count
    code = datum[field]
    axis = (if code is x_code then "x" else "y")
    other_axis = (if axis is "x" then "y" else "x")
    unless aggregated.hasOwnProperty(dataPoint)
      aggregated[dataPoint] = {}
      aggregated[dataPoint][axis] = count
      aggregated[dataPoint][other_axis] = 0
    else
      aggregated[dataPoint][axis] += count
  
  # FLATTEN
  for dataPoint of aggregated
    datum = aggregated[dataPoint]
    x = datum.x
    y = datum.y
    d =
      id: dataPoint
      name: dataPoint
      active1: true
      active2: true
      year: 2002

    d[x_name] = x
    d[y_name] = y
    d["total"] = x + y
    flatData.push d
  text_formatting = (d) ->
    d.charAt(0).toUpperCase() + d.substr(1)

  inner_html = (obj) ->
    "This is some test HTML"

  # console.log("orignal data", data);
  # console.log("aggregated", aggregated);
  # console.log("FLAT DATA: ", flatData);
  # console.log("ATTRS: ", attrs);

  Deps.autorun( ->
    scaleType = Session.get("scatterplotScale")
    mirrorType = (Session.get("scatterplotMirror") is "true")

    viz.type("pie_scatter")
      .width($(".page-middle").width() - 20)
      .height($(".page-middle").height() - 20).id_var("id")
      .attrs(attrs)
      .text_var("name")
      .xaxis_var(x_name)
      .yaxis_var(y_name)
      .xscale_type(scaleType)
      .yscale_type(scaleType)
      # .value_var("total")
      .nesting(nesting)
      .depth(nestingDepth)
      .text_format(text_formatting)
      .spotlight(false)
      .active_var("active1")
      .click_function(inner_html)
      .font_weight(300)
      .background("#000000")
      .font("Lato")
      .mirror_axis(mirrorType)

    d3.select(context.find("svg")).datum(flatData).call viz
  )
  
  