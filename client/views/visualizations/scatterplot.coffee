scatterplotProps =
  width: 725
  height: 560

Template.scatterplot_svg.properties = scatterplotProps

Template.scatterplot_svg.destroyed = ->
  # Stop any reactive computation from rendered
  @computation?.stop()

Template.scatterplot_svg.rendered = ->
  context = this
  mobile = Session.get("mobile")
  embed = Session.get("embed")
  width = $(".page-middle").width()
  height = $(".page-middle").height() - 80
  if mobile
    height = 200
  if embed 
    height = $(".page-middle").height()/2 - 60
  
  viz = d3plus.viz()
  vizMode = Session.get("vizMode")
  if vizMode is "country_vs_country"
    x_field = "countryCode"
    y_field = "countryCode"
    x_code = Session.get("countryX")
    y_code = Session.get("countryY")
    # Need to work entirely in country codes because code -> name is not one-to-one
    x_name = x_code  # Countries.findOne(countryCode: x_code).countryName
    y_name = y_code  # Countries.findOne(countryCode: y_code).countryName
    x_label = if x_name is "all" then "The World" else Countries.findOne(countryCode: x_code).countryName
    y_label = if y_name is "all" then "The World" else Countries.findOne(countryCode: y_code).countryName
    aggregatedField = "occupation"
    nesting = ["nesting_1", "nesting_3", "nesting_5"]
    nestingDepth = "nesting_5"
  else if vizMode is "domain_vs_domain"
    # field = "domain"
    x_field = Session.get("categoryLevelX")
    y_field = Session.get("categoryLevelY")
    x_code = Session.get("categoryX")
    y_code = Session.get("categoryY")
    x_name = x_code
    y_name = y_code
    x_label = x_code.capitalize()
    y_label = y_code.capitalize()
    aggregatedField = "countryCode"
    nesting = ["nesting_1", "nesting_3"]
    nestingDepth = "nesting_3"

  Deps.autorun( ->
    context.computation = this
    data = Scatterplot.find().fetch()
  
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
      match_x = if datum[x_field] is x_code then true else false
      match_y = if datum[y_field] is y_code then true else false

      if aggregated.hasOwnProperty(dataPoint)
        if match_x then aggregated[dataPoint].x += count
        if match_y then aggregated[dataPoint].y += count
      else
        aggregated[dataPoint] = x: 0, y: 0
        if match_x then aggregated[dataPoint].x = count
        if match_y then aggregated[dataPoint].y = count
    
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
  
    dataset = Session.get("dataset")
    L = Session.get("langs")
    scaleType = Session.get("scatterplotScale")
    mirrorType = Session.get("scatterplotMirror")

    viz.type("pie_scatter")
      .width(width)
      .height(height)
      .id_var("id")
      .attrs(attrs)
      .text_var("name")
      .xaxis_label(x_label)
      .yaxis_label(y_label)
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
  
  