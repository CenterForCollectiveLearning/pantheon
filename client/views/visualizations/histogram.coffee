histProps = 
    width: 725
    height: 560
    margin:
        top: 50
        right: 60
        bottom: 5
        left: 60

Template.histogram_svg.properties = 
    fullWidth: histProps.width + histProps.margin.left + histProps.margin.right
    fullHeight: histProps.height + histProps.margin.top + histProps.margin.bottom

Template.histogram_svg.rendered = ->
    context = this

    # Visualization Parameters and Objects
    # TODO Don't be redundant
    histProps.fullWidth = $(".page-middle").width()
    histProps.fullHeight = histProps.height + histProps.margin.top + histProps.margin.bottom
    histProps.width = histProps.fullWidth - histProps.margin.left - histProps.margin.right

    # TODO Fully understand this
    formatNumber = (value) ->
        # if value < 1 then d3.round value, 2
        # Format number to precision level using proper scale
        value = d3.formatPrefix(value).scale(value)
        value = parseFloat(d3.format(".3g")(value))
        d3.format(",3f") value

    barPadding = 0.2
    x = d3.scale.linear().range([0, histProps.width])
    y = d3.scale.ordinal().rangeRoundBands([0, histProps.height], barPadding)
    xAxis = d3.svg.axis().scale(x).orient("top").tickFormat(formatNumber)

    svg = d3.select(@find("svg.histogram"))
        .attr("width", histProps.fullWidth)
        .attr("height", histProps.fullHeight)
      .append("g")
        .attr("transform", "translate(" + histProps.margin.left + "," + histProps.margin.top + ")")
    
    change = -> clearTimeout sortTimeout

    data = Histogram.find().fetch()

    vizMode = Session.get "vizMode"
    if vizMode is "country_exports"
        yVar = 'industry'
    else if vizMode is "domain_exports_to"    
        yVar = 'countryName'

    mouseover = (p) ->
        Session.set "hover", true
        console.log p
  
        # Positioning
        position =
          left: (d3.event.pageX + 40)
          top: (d3.event.pageY - 45)
  
        Session.set "tooltipPosition", position
        rca = p.rca
        if vizMode is "country_exports"
            countryCode = Session.get "country"
            countryName = Countries.findOne(countryCode: countryCode).countryName
            category = p[yVar]
            categoryLevel = "industry"    
        else if vizMode is "domain_exports_to"
            countryCode = p.countryCode
            countryName = p.countryName
            category = Session.get "category"
            categoryLevel = Session.get "categoryLevel"

        console.log countryCode, countryName, category, categoryLevel
        
        # Subscription Parameters
        Session.set "tooltipCategory", category
        Session.set "tooltipCategoryLevel", categoryLevel
        Session.set "tooltipCountryCode", countryCode
        
        # Retrieve and pass data to template
        Template.tooltip.heading = countryName + ": " + category
        Template.tooltip.categoryA = countryName
        Template.tooltip.categoryB = category
        Session.set "showTooltip", true

        xVal = x(Math.min(1, rca)) 
        if rca >= 1 then xVal += Math.abs(x(rca) - x(1))
        xText = formatNumber rca
        yVal = y category
        radius = 5
        color = "white"

        # vertical line to x-axis
        svg.append("line")
            .attr("class", "axis_hover")
            .attr("x1", xVal)
            .attr("x2", xVal)
            .attr("y1", 0)   # offset so hover doens't flicker
            .attr("y2", yVal+radius+1)
            .attr("stroke", color)
            .attr("stroke-width", 1)
            .attr("shape-rendering","crispEdges")

        # x-axis value box
        xrect = svg.append("rect")
            .attr("class", "axis_hover")
            .attr("y", histProps.height)
            .attr("height", 20)
            .attr("fill", "white")
            .attr("stroke", "white")
            .attr("stroke-width", 1)
            .attr("shape-rendering","crispEdges")
    
        # xvalue text element
        xtext = svg.append("text")
            .attr("class", "axis_hover")
            .attr("x", xVal)
            .attr("y", 0)
            .attr("dy", -25)
            .attr("text-anchor","middle")
            .style("font-weight", "lighter")
            .attr("font-size","12px")
            .attr("font-family","Lato")
            .attr("fill","#FFF")
            .text(xText)

    mouseout = (p) ->
        Template.tooltip.top5 = null
        Session.set "hover", false
        Session.set "showTooltip", false
        $("#tooltip").empty()
        d3.selectAll(".axis_hover").remove()

    clickevent = (p) ->
      Session.set "hover", false
      Session.set "showTooltip", false
      dataset = Session.get("dataset")

      if vizMode is "country_exports"
        countryCode = Session.get "country"
        countryName = Countries.findOne({countryCode: countryCode, dataset:dataset}).countryName
        category = p[yVar]
        categoryLevel = "industry"
      else if vizMode is "domain_exports_to"
        countryCode = p.countryCode
        countryName = p.countryName
        category = Session.get "category"
        categoryLevel = Session.get "categoryLevel"

      # Subscription Parameters
      Session.set "bigtooltipCategory", category
      Session.set "bigtooltipCategoryLevel", categoryLevel
      Session.set "bigtooltipCountryCode", countryCode
      Template.clicktooltip.title = countryName + ": " + category
      Session.set "clicktooltip", true

    x.domain(d3.extent(data, (d) -> d.rca)).nice()
    y.domain(data.map((d) -> 
        console.log d[yVar], yVar
        d[yVar]))

    svg.selectAll(".bar")
        .data(data)
      .enter()
        .append("rect")
        .attr("class", (d) -> (if d.rca < 1 then "bar negative" else "bar positive"))
        .attr("x", (d) -> x Math.min(1, d.rca))
        .attr("y", (d) -> y d[yVar])
        .attr("width", (d) -> Math.abs(x(d.rca) - x(1)))
        .attr("height", y.rangeBand())
        .on("mousemove", mouseover)
        .on("mouseout", mouseout)
        .on("click", clickevent)

    svg.selectAll("text")
        .data(data)
      .enter()
        .append("text")
        .attr("class", "label")
        .text((d) -> d[yVar])
        .attr("x", (d) ->
            xVal = x Math.min(1, d.rca)
            if d.rca >= 1 then xVal += Math.abs(x(d.rca) - x(1))
            xVal)
        .attr("dx", (d) -> if d.rca >= 1 then "0.2em" else "-0.2em")
        .attr("y", (d) -> y(d[yVar]) + (histProps.height / (data.length + barPadding)) / 2)
        .attr("text-anchor", (d) -> if d.rca >= 1 then "start" else "end")
        .attr("font-family", "Lato")
        .attr("fill", "#ffffff")
        .attr("font-weight", "lighter")
        .attr("font-size", "0.8em")

    svg.append("g")
        .attr("class", "x axis")
        .call xAxis

    svg.append("g")
        .attr("class", "y axis")
      .append("line")
        .attr("x1", x(1))
        .attr("x2", x(1))
        .attr("y2", histProps.height)

    Deps.autorun ->

        change = (order) ->
            # Copy-on-write since tweens are evaluated after a delay.
            sortedData = data.sort(if industryOrder is "count" then (a, b) -> b.rca - a.rca else (a, b) -> d3.ascending(a[yVar], b[yVar])).map((d) -> d[yVar])
            yNew = y.domain(sortedData).copy()

            transition = svg.transition().duration(750)
            delay = (d, i) -> i * 50  # Staggered delay

            transition.selectAll(".bar").delay(delay).attr "y", (d) -> yNew d[yVar]
            transition.selectAll(".label").delay(delay).attr "y", (d) -> yNew(d[yVar]) + (histProps.height / (data.length + barPadding)) / 2

        countryOrder = Session.get "countryOrder"
        industryOrder = Session.get "industryOrder"
        if vizMode is "country_exports"
            order = industryOrder
        else if vizMode is "domain_exports_to"
            order = countryOrder
        change order
        