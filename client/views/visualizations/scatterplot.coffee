# TODO Namespace these
scatterplotProps =
  width: 725
  height: 560

Template.scatterplot_svg.properties = scatterplotProps

boilingOrange = "#F29A2E"
chiliRed = "#C14925"
sapGreen = "#587507"
brickBrown = "#72291D"
seaGreen = "#46AF69"
salmon = "#EB7151"
manganeseBlue = "#129B97"
magenta = "#822B4C"

color_domains = d3.scale.ordinal()
  .domain(["INSTITUTIONS", "ARTS", "HUMANITIES", "BUSINESS & LAW", "EXPLORATION", "PUBLIC FIGURE", "SCIENCE & TECHNOLOGY", "SPORTS", "Art", "Lit", "Music", "Phil", "Science"])
  .range([salmon, boilingOrange, brickBrown, sapGreen, chiliRed, seaGreen, manganeseBlue, magenta, boilingOrange, brickBrown, salmon, chiliRed, magenta, manganeseBlue])

color_countries = d3.scale.ordinal()
  .domain(["Africa", "Asia", "Europe", "North America", "South America", "Oceania", "Unknown"])
  .range([salmon, boilingOrange, brickBrown, sapGreen, chiliRed, seaGreen, manganeseBlue, magenta])

Template.scatterplot_svg.rendered = ->
  context = this
  width = $(".page-middle").width() - 10
  height = $(".page-middle").height() - 80
  
  viz = d3plus.viz()
  vizMode = Session.get("vizMode")
  if vizMode is "country_vs_country"
    field = "countryCode"
    x_code = Session.get("countryX")
    y_code = Session.get("countryY")
    x_name = x_code  # Countries.findOne(countryCode: x_code).countryName
    y_name = y_code  # Countries.findOne(countryCode: y_code).countryName
    aggregatedField = "occupation"
    nesting = ["nesting_1", "nesting_3", "nesting_5"]
    nestingDepth = "nesting_3"
  else if vizMode is "domain_vs_domain"
    field = "domain"
    x_code = Session.get("categoryX")
    y_code = Session.get("categoryY")
    x_name = x_code
    y_name = y_code
    aggregatedField = "countryCode"
    nesting = ["nesting_1", "nesting_3"]
    nestingDepth = "nesting_3"

  Deps.autorun( ->
    data = Scatterplot.find().fetch()
    console.log
  
    aggregated = {} # X, Y values for each data point (eg. {WRITER: {x:1, y:5}})
    flatData = [] # Array of objects {xname: 130, yname:87, id: PHYSICIST}
    attrs = {}
    if vizMode is "country_vs_country"
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
        continent_color = color_countries(continent)
        continentDict =
          id: continent
          name: continent
  
        countryDict =
          id: countryCode
          name: countryCode
  
        attrs[continent] =
          id: continent
          name: continent
          color: continent_color
          nesting_1: continentDict
  
        attrs[countryCode] =
          id: countryCode
          name: countryCode
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
  
      d[x_code] = x
      d[y_code] = y
      d["total"] = x + y
      flatData.push d
    text_formatting = (d) ->
      d.charAt(0).toUpperCase() + d.substr(1)
  
    console.log data
    console.log flatData
    console.log attrs
  
    dataset = Session.get("dataset")
    L = Session.get("langs")
    scaleType = Session.get("scatterplotScale")
    mirrorType = Session.get("scatterplotMirror")

    console.log "creating viz", x_name, y_name
    
    viz.type("pie_scatter")
      .width(width)
      .height(height)
      .id_var("id")
      .attrs(attrs)
      .text_var("name")
      .xaxis_var(x_name)
      .yaxis_var(y_name)
      .xscale_type(scaleType)
      .yscale_type(scaleType)
      .value_var("total")
      .nesting(nesting)
      .depth(nestingDepth)
      .text_format(text_formatting)
      .spotlight(false)
      .active_var("active1")
      .font_weight(300)
      .background("#f9f6e1")
      .font("Lato")
      .mirror_axis(mirrorType)

    d3.select(context.find("svg")).datum(flatData).call viz
  )
  
  