# http://bl.ocks.org/mbostock/3885705

histProps = 
    width: 725
    height: 560
    margin:
        top: 50
        right: 10
        bottom: 5
        left: 30

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
    formatNumber = (value, name) ->
        # if value < 1 then d3.round value, 2
        # Format number to precision level using proper scale
        value = d3.formatPrefix(value).scale(value)
        value = parseFloat(d3.format(".3g")(value))
        d3.format(",3f") value

    barPadding = 0.2
    x = d3.scale.log().range([0, histProps.width])
    y = d3.scale.ordinal().rangeRoundBands([0, histProps.height], barPadding)
    xAxis = d3.svg.axis().scale(x).orient("top").tickFormat(formatNumber)

    # formatPercent = d3.format(".0%")
    # x = d3.scale.log().range([0, histProps.width])
    # y = d3.scale.ordinal().rangeRoundBands([0, histProps.height], .1, 1)
    # xAxis = d3.svg.axis().scale(x).orient("top")
    # yAxis = d3.svg.axis().scale(y).orient("left").tickFormat(formatNumber)
    svg = d3.select(@find("svg.histogram"))
        .attr("width", histProps.fullWidth)
        .attr("height", histProps.fullHeight)
      .append("g")
        .attr("transform", "translate(" + histProps.margin.left + "," + histProps.margin.top + ")")
    # change = -> clearTimeout sortTimeout

    data = Histogram.find().fetch()

    # TODO Include y-axis guideline
    mouseover = (p) ->
        Session.set "hover", true
  
        # Positioning
        position =
          left: (d3.event.pageX + 40)
          top: (d3.event.pageY - 45)
  
        Session.set "tooltipPosition", position
        countryCode = Session.get "country"
        countryName = Countries.findOne(countryCode: countryCode).countryName
  
        industry = p.industry
        categoryLevel = "industry"
        
        # Subscription Parameters
        Session.set "tooltipCategory", industry
        Session.set "tooltipCategoryLevel", categoryLevel
        Session.set "tooltipCountryCode", countryCode
        
        # Retrieve and pass data to template
        Template.tooltip.heading = countryName + ": " + industry
        Template.tooltip.categoryA = countryName
        Template.tooltip.categoryB = industry
        Session.set "showTooltip", true
    mouseout = (p) ->
        Template.tooltip.top5 = null
        Session.set "hover", false
        Session.set "showTooltip", false
        $("#tooltip").empty()
        d3.selectAll("text").classed "active", false

    x.domain(d3.extent(data, (d) -> d.rca)).nice()
    y.domain(data.map((d) -> d.industry))

    svg.selectAll(".bar")
        .data(data)
      .enter()
        .append("rect")
        .attr("class", (d) -> (if d.rca < 1 then "bar negative" else "bar positive"))
        .attr("x", (d) -> x Math.min(1, d.rca))
        .attr("y", (d) -> y d.industry)
        .attr("width", (d) -> Math.abs(x(d.rca) - x(1)))
        .attr("height", y.rangeBand())
        .on("mousemove", mouseover)
        .on("mouseout", mouseout)

    svg.selectAll("text")
        .data(data)
      .enter()
        .append("text")
        .attr("class", (d) -> d.industry)
        .text((d) -> d.industry)
        .attr("x", (d) -> 
            xVal = x Math.min(1, d.rca)
            if d.rca >= 1 
                xVal += Math.abs(x(d.rca) - x(1))
            console.log xVal
            xVal)
        .attr("dx", "0.2em")
        .attr("y", (d) -> y(d.industry) + (histProps.height / (data.length + barPadding)) / 2) #+ (histProps.height / data.length - barPadding) / 2)
        # .attr("text-anchor", "middle")
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

    # # TODO Make this correct
    # # Copy-on-write since tweens are evaluated after a delay.
    # x0 = x.domain(data.sort((if @checked then (a, b) -> b.rca - a.rca else (a, b) -> d3.ascending a.industry, b.industry)).map((d) -> d.industry)).copy()

    # transition = svg.transition().duration(750)
    # delay = (d, i) -> i * 50

    # transition.selectAll(".bar").delay(delay).attr "x", (d) -> x0 d.industry

    # transition.select(".x.axis").call(xAxis).selectAll("g").delay delay

    # x.domain data.map (d) -> d.industry
    # # What is the proper domain? 

    # y0 = Math.max(-d3.min(data, (d) -> d.rca), d3.max(data, (d) -> d.rca))

    # x.domain(d3.extent(data, (d) -> d.rca)).nice()

    

    # svg.append("g")
    #     .attr("class", "x axis")
    #     .call(xAxis)
    #     .attr("font-family", "Lato")
    #     .attr("font-size", "0.8em")

    # svg.append("g")
    #     .attr("class", "y axis")
    # .append("line")
    #     .attr("x1", x(0))
    #     .attr("x2", x(0))
    #     .attr("y2", height)
    # .append("text")
    #     .attr("transform", "rotate(-90)")
    #     .attr("y", 6)
    #     .attr("dy", ".71em")
    #     .attr("font-family", "Lato")
    #     .attr("font-size", "0.8em")
    #     .style("text-anchor", "end")
    #     .text("Revealed Competitive Advantage")
    
    # # svg.append("g")
    # #     .attr("class", "y axis")
    # #     .call(yAxis)
    # #     .attr("y1", y(0))
    # #     .attr("y2", y(0))
    # #   .append("text")
    # #     .attr("transform", "rotate(-90)")
    # #     .attr("y", 6)
    # #     .attr("dy", ".71em")
    # #     .attr("font-family", "Lato")
    # #     .attr("font-size", "0.8em")
    # #     .style("text-anchor", "end")
    # #     .text("Revealed Competitive Advantage")

    # svg.selectAll(".bar")
    #     .data(data)
    #   .enter().append("rect")
    #     .attr("class", (d) -> if x(d.rca) < 0 ? "bar negative" else "bar positive")
    #     .attr("x", (d) -> x Math.min(0, d.rca))
    #     .attr("width", x.rangeBand())
    #     .attr("y", (d) -> y d.industry)
    #     .attr("height", (d) -> histProps.height - y(d.rca))
    #     .on("mousemove", mouseover)
    #     .on("mouseout", mouseout)


  # d3.select("input").on "change", change
  # sortTimeout = setTimeout(->
  #   d3.select("input").property("checked", true).each change
  # , 2000)