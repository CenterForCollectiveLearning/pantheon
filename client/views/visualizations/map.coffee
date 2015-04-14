
# Creates the legend for the svg
key_gradient = (rect) ->
  gradient = d3.select("svg").append("defs").append("linearGradient").attr(
    id: "gradient"
    x1: "0%"
    x2: "100%"
    y1: "0%"
    y2: "0%"
    spreadMethod: "pad"
  )
  i = 0

  while i <= 100
    percent = Math.round((1 * Math.pow((100 / 1), i / 100)))
    gradient.append("stop").attr("offset", percent + "%").attr("stop-color", color_gradient[i / 20]).attr "stop-opacity", 1
    i = i + 20
  rect.attr(
    x: 0
    y: 0
    width: $(".page-middle").width()
    height: 10
  ).style "fill", "url(#gradient)"

mouseoverCity = (d) ->
  if not Session.get "clicktooltip"
    Session.set "hover", true

    category = Session.get("category")
    categoryAggregation = Session.get("categoryLevel")
    position = getTooltipPosition(d3.event.pageX, d3.event.pageY)

    Session.set "tooltipPosition", position
    
  #   # Subscription Parameters
    Session.set "tooltipCategory", category
    Session.set "tooltipCategoryLevel", categoryAggregation
    Session.set "tooltipCountryCode", d.birthcountryCode
    Session.set "tooltipCity", d.birthplace
    
  #   # Retrieve and pass data to template
    Template.tooltip.heading = d.birthplace + ", " + d.birthcountryName.capitalize()
    Template.mobile_tooltip_ranking.heading = (if category isnt "all" then d.birthcountryName + ": " + category else d.birthcountryName)
    Template.tooltip.categoryA = d.birthcountryName
    Template.tooltip.categoryB = category
    Template.tooltip.data = ClientPeople.find("birthcity":d.birthplace, "countryCode":d.birthcountryCode,
            "birthyear": {"$gte": Session.get("from"), "$lte": Session.get("to")} , "dataset": "OGC").fetch()
    Session.set "showTooltip", true  

mouseoverCountry = (d) ->
  if not Session.get "clicktooltip"
    Session.set "hover", true
    dataset = Session.get("dataset")
    countryCode3 = d.id
    # change this so only use dataset: OGC for the countryNames 
    countryName = Countries.findOne({countryCode3: countryCode3, dataset:"OGC"}).countryName
    if(dataset is "murray")
      countryCode = countryCode3
    else
      countryCode = Countries.findOne({countryCode3: countryCode3, dataset:dataset}).countryCode
    category = Session.get("category")
    categoryAggregation = Session.get("categoryLevel")
    position = getTooltipPosition(d3.event.pageX, d3.event.pageY)

    Session.set "tooltipPosition", position
    
    # Subscription Parameters
    Session.set "tooltipCategory", category
    Session.set "tooltipCategoryLevel", categoryAggregation
    Session.set "tooltipCountryCode", countryCode
    Session.set "tooltipCity", "all"
    
    # Retrieve and pass data to template
    Template.tooltip.heading = countryName + ": " + category
    Template.mobile_tooltip_ranking.heading = (if category isnt "all" then countryName + ": " + category else countryName)
    Template.tooltip.categoryA = countryName
    Template.tooltip.categoryB = category
    Session.set "showTooltip", true

mouseoutCity = (d) ->
  Session.set "hover", false
  Session.set "showTooltip", false
  mouseoverCell = null

mouseoutCountry = (d) ->
  Session.set "hover", false
  Session.set "showTooltip", false
  mouseoverCell = null

mouseover = (d) ->
  if not Session.get "clicktooltip"
    Session.set "hover", true
    # change outline of selected country on mouseover
    d3.select(@parentNode.appendChild(this)).transition().duration(200).style
      "stroke-opacity": 1
      "stroke-width":1.5
      stroke: "#222"

    dataset = Session.get("dataset")
    countryCode3 = d.id
    # change this so only use dataset: OGC for the countryNames 
    countryName = Countries.findOne({countryCode3: countryCode3, dataset:"OGC"}).countryName
    if(dataset is "murray")
      countryCode = countryCode3
    else
      countryCode = Countries.findOne({countryCode3: countryCode3, dataset:dataset}).countryCode
    category = Session.get("category")
    categoryAggregation = Session.get("categoryLevel")
    position = getTooltipPosition(d3.event.pageX, d3.event.pageY)

    Session.set "tooltipPosition", position
    
    # Subscription Parameters
    Session.set "tooltipCategory", category
    Session.set "tooltipCategoryLevel", categoryAggregation
    Session.set "tooltipCountryCode", countryCode
    
    # Retrieve and pass data to template
    Template.tooltip.heading = countryName + ": " + category
    Template.mobile_tooltip_ranking.heading = (if category isnt "all" then countryName + ": " + category else countryName)
    Template.tooltip.categoryA = countryName
    Template.tooltip.categoryB = category
    Session.set "showTooltip", true

mouseout = (d) ->
  Session.set "hover", false
  Session.set "showTooltip", false
  mouseoverCell = null
  # remove the outline on mouseout
  d3.select(@parentNode.appendChild(this)).transition().duration(200).style
    "stroke-opacity": 0.4
    stroke: "#eee"
    "stroke-width": 0.5

clickevent = (d) ->
  if Session.equals("tutorialType", null) or Session.equals("tutorialType", undefined)
    Session.set "hover", false
    Session.set "showTooltip", false
    dataset = Session.get("dataset")
    countryCode3 = d.id
    countryName = Countries.findOne({countryCode3: countryCode3, dataset:"OGC"}).countryName
    if dataset is "murray"
      countryCode = countryCode3
    else
      countryCode = Countries.findOne({countryCode3: countryCode3, dataset:dataset}).countryCode
    category = Session.get("category")
    categoryAggregation = Session.get("categoryLevel")
    # Subscription Parameters
    Session.set "bigtooltipCategory", category
    Session.set "bigtooltipCategoryLevel", categoryAggregation
    Session.set "bigtooltipCountryCode", countryCode
    Template.clicktooltip.title = (if category isnt "all" then countryName + ": " + category else countryName)
    Session.set "clicktooltip", true



# TODO optional: un-highlight country
get_range_log = (data, num_buckets) ->
  min = d3.min(data, (c) ->
    c.count
  )
  max = d3.max(data, (c) ->
    c.count
  )
  base = max / min
  range = [min]
  i = 1

  while i < num_buckets
    range.push min * Math.pow(base, i / num_buckets)
    i++
  range.push max
  range
Template.map.dataReady = ->
  Session.get "dataReady"

mapProps =
  width: 700
  height: 560
  margin:
    top: 10
    right: 10
    bottom: 10
    left: 10

Template.map_svg.properties = mapProps
color_gradient = ["#f2ecb4", "#f2e671", "#f6d626", "#f9b344", "#eb8c30", "#e84d24"]

Template.map_svg.rendered = ->
  data = WorldMap.find().fetch()

  vars =
      svg_height : 485
      svg_width : $(".page-middle").width()

  mobile = Session.get("mobile")
  if mobile
    vars =
      svg_height : 200
      svg_width : $(".page-middle").width()

  embed = Session.get("embed")
  if embed
    vars =
      svg_height : $(".page-middle").height()/2 - 160
      svg_width : $(".page-middle").width()

  if data.length is 0 #No data screen
    error = d3.select(@firstNode).attr("width", vars.svg_width).attr("height", vars.svg_height).append("svg:g").selectAll("g.d3plus-error").data(["No data available"])
    error.enter().append("rect").attr("width", vars.svg_width).attr("height", vars.svg_height).attr("fill", "#f9f6e1")
    error.enter().append("g").attr("class", "d3plus-error").attr("opacity", 100).append("text").attr("x", vars.svg_width / 2).attr("font-size", "30px").attr("fill", "#222").attr("text-anchor", "middle").attr("font-family", "Lato").style("font-weight", "300").each((d) ->
      d3plus.utils.wordwrap
        text: d
        parent: this
        width: vars.svg_width - 20
        height: vars.svg_height - 20
        resize: false

    ).attr "y", ->
      height = d3.select(this).node().getBBox().height
      vars.svg_height / 2 - height / 2
  else
    if mobile
      value_range = get_range_log(data, 5)
      value_range_big = get_range_log(data, 10)
      background = d3.select(@firstNode)
          .attr("width", vars.svg_width)
          .attr("height", vars.svg_height)
        .append("svg:g")
          .attr("id", "background")
        .append("rect")
          .attr("width", vars.svg_width)
          .attr("height", vars.svg_height)
          .attr("fill", "#000000") # "#f9f6e1")
          .attr("fill-opacity", 0.4)
    else
      value_range = get_range_log(data, 5)
      value_range_big = get_range_log(data, 10)
      background = d3.select(@firstNode)
          .attr("width", vars.svg_width)
          .attr("height", vars.svg_height)
        .append("svg:g")
          .attr("id", "background")
        .append("rect")
          .attr("width", vars.svg_width)
          .attr("height", vars.svg_height)
          .attr("fill", "#f9f6e1")

    svg = d3.select(@firstNode)
        .attr("width", vars.svg_width)
        .attr("height", vars.svg_height)
      .append("svg:g")
        .attr("id", "countries")

    map_projection = d3.geo.equirectangular()
        .scale(vars.svg_width * 0.14)
        .translate([vars.svg_width / 2, vars.svg_height / 2])

    keyX_translate = 0 # (vars.svg_width - 640)/2 - 20
    keyY_translate = if mobile then 170 else 450

    value_color = d3.scale.log().domain(value_range).interpolate(d3.interpolateRgb).range([color_gradient[0], color_gradient[1], color_gradient[2], color_gradient[3], color_gradient[4], color_gradient[5]])
    svg.selectAll("path").data(d3.values(mapData.features)).enter().append("path").attr("id", (d, i) ->
      d.id
    ).attr("stroke", "#eee").attr("stroke-width", 0.5).attr "d", d3.geo.path().projection(map_projection)

    scalewidth = $(".page-middle").width()
    colorScale = d3.select(@find("svg.color-scale")).attr("width", scalewidth).attr("height", "30px").append("g") 
    key_enter = colorScale.append("g").attr("class", "key").append("rect").call(key_gradient)
    d3.select(".key").selectAll("rect.ticks").data(value_range_big).enter().append("rect").attr("class", "ticks").attr("x", (d, i) ->
      Math.round (50 * Math.pow(((scalewidth-15) / 50), i / 10))
    ).attr("y", 0).attr("width", 2).attr("height", 10).style "fill", "#fff"
    d3.select(".key").selectAll("text").data(value_range_big).enter().append("text").attr("x", (d, i) ->
      Math.round (50 * Math.pow(((scalewidth-15) / 50), i / 10))
    ).attr("y", 12).attr("dy", 12).attr("text-anchor", "middle").style "fill", "#222"

    # SPRING DEMO - SHOW THE TOP 100 CITIES IN THE MAPS VIEW
    if Session.equals("category", "all")
      svg.selectAll("path").attr("fill", (d) ->
          doc = WorldMap.findOne(countryCode: d.id)
          if doc then value_color doc.count
          else "#FFF"
        ).on("mouseover", mouseoverCountry)
        .on("mouseout", mouseoutCountry).on("click", (d) ->
          if Session.get("mobile") or Session.get("embed") then mouseover(d)
          else clickevent(d)
          )
      g = svg.append("g")
      d3.csv "/top100cities.csv", (error, data) ->
        g.selectAll("circle").data(data).enter().append("a").attr("xlink:href", (d) ->
          "/treemap/country_exports/" + d.birthplace + "+" + d.birthcountryCode + "/all/-4000/2010/H15/pantheon"
        ).append("circle").attr("cx", (d) ->
          map_projection([
            d.birthLON
            d.birthLAT
          ])[0]
        ).attr("cy", (d) ->
          map_projection([
            d.birthLON
            d.birthLAT
          ])[1]
        ).attr("r", 3)
        .style("stroke", "white",).style("fill", "grey")
        .style("stroke-width", "2px").on("mouseover", (d) -> 
          mouseoverCity(d)).on("mouseout", mouseoutCity)
        return
    else # the below is the default 
      svg.selectAll("path").attr("fill", (d) ->
        doc = WorldMap.findOne(countryCode: d.id)
        if doc then value_color doc.count
        else "#FFF"
      ).on("mouseover", mouseover)
      .on("mouseout", mouseout)
      .on("click", (d) ->
        if Session.get("mobile") or Session.get("embed") then mouseover(d)
        else clickevent(d)
        )
      .on("touchstart", "mouseover")
      .on("touchend", "mouseout")

    d3.select(".key").selectAll("text").text (d, i) ->
      value_range_big[i].toFixed 0

    # make the treemap zoomable using d3.behavior.zoom()
    zoom = d3.behavior.zoom()
    .scaleExtent([1, 5])
    .on("zoom", ->
        svg.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")")
      )
    svg.call(zoom)


mouseoverCell = null
