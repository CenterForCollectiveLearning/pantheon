# TODO Pull this out of here
matrixProps =
  width: 660
  height: 2000
  headerHeight: 155
  margin:
    top: 10
    right: 10
    bottom: 5
    left: 30

Template.matrix_svg.properties = 
    headerHeight: matrixProps.headerHeight
    fullWidth: matrixProps.width + matrixProps.margin.left + matrixProps.margin.right
    fullHeight: matrixProps.height + matrixProps.margin.top + matrixProps.margin.bottom

Template.matrix_svg.rendered = ->
  context = this
  
  # Visualization width (NOT SVG width)
  matrixProps.fullWidth = $(".page-middle").width()
  matrixProps.width = matrixProps.fullWidth - matrixProps.margin.left - matrixProps.margin.right

  matrixScales =
    x: d3.scale.ordinal().rangeBands([0, matrixProps.height])
    y: d3.scale.ordinal().rangeBands([0, matrixProps.width])
    z: d3.scale.linear().domain([0, 1]).clamp(true)
    c: d3.scale.category10().domain(d3.range(10))

  data = Matrix.find().fetch()

  # No data screen
  if data.length is 0 
    vars =
      svg_height : $(".page-middle").height()
      svg_width : $(".page-middle").width() - 80
    d3.select(@find("svg.matrix")).remove()
    $("div.scroll-container").remove()
    error = d3.select(@find("svg.header")).attr("width", vars.svg_width).attr("height", vars.svg_height).append("svg:g").selectAll("g.d3plus-error").data(["No data available"])
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
    # SVG Handles 
    svg = d3.select(@find("svg.matrix")).attr("width", matrixProps.fullWidth).append("g").attr("transform", "translate(" + matrixProps.margin.left + "," + 0 + ")")
    header_svg = d3.select(@find("svg.header")).attr("width", matrixProps.fullWidth).append("g").attr("transform", "translate(" + matrixProps.margin.left + "," + matrixProps.headerHeight + ")")

    # TODO: Don't re-render tooltip for already selected cell
    clickevent = (p) ->
      if Session.equals("tutorialType", null) or Session.equals("tutorialType", undefined)
        Session.set "hover", false
        Session.set "showTooltip", false
        $("#tooltip").empty()
        dataset = Session.get("dataset")

        countryCode = countries[p.y]
        countryName = Countries.findOne({countryCode: countryCode, dataset:dataset}).countryName

        industry = industries[p.x]
        categoryLevel = "industry"

        # Subscription Parameters
        Session.set "bigtooltipCategory", industry
        Session.set "bigtooltipCategoryLevel", categoryLevel
        Session.set "bigtooltipCountryCode", countryCode
        Session.set "clicktooltip", true
        Template.clicktooltip.title = countryName + ": " + industry
    mouseover = (p) ->
      if not Session.get "clicktooltip"
        Session.set "hover", true
        # outline cell on mouseover
        d3.select(@parentNode.appendChild(this)).transition().duration(200).style
          stroke: "#222222"
          "stroke-opacity": 1
          "stroke-width":2
        
        d3.selectAll(".row text").classed "active", (d, i) -> i is p.y
        d3.selectAll(".column-title text").classed "active", (d, i) -> i is p.x
        # Positioning
        position =
          left: (d3.event.pageX + 40)
          top: (d3.event.pageY - 45)
        Session.set "tooltipPosition", position
        countryCode = countries[p.y]
        countryName = Countries.findOne(countryCode: countryCode).countryName
        industry = industries[p.x]
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
      # remove outline on mouseout??
      d3.select(@parentNode.appendChild(this)).transition().duration(200).style
        "stroke-opacity": 0
        stroke: "#eee"
      Session.set "showTooltip", false
      $("#tooltip").empty()
      d3.selectAll("text").classed "active", false
    countries = []
    industries = []
    maxValue = 0
    countryCounts = {}
    industryCounts = {}
    for datum in data
      countryCode = datum.countryCode
      industry = datum.industry
      count = datum.count
      countries.push countryCode if countryCode not in countries
      industries.push industry if industry not in industries
      countryCounts[countryCode] ?= 0
      countryCounts[countryCode] += 1
      industryCounts[industry] ?= 0
      industryCounts[industry] += 1
      if count > maxValue then maxValue = count


    if Session.equals("gender", "ratio")
      colorArray = ["blue", "white" ,"red"]
      fill = d3.scale.linear()
      domainArray = [0, 1, maxValue]
      fill.domain(domainArray)
      fill.range(colorArray)
    else
      colorArray = ["#ffff95", "orange", "red"]
      fill = d3.scale.log().domain([1, maxValue])
      domainArray = [0, 0.5, 1].map(fill.invert)
      fill.domain(domainArray)
      fill.range(colorArray)

    # TODO Make this code not suck and make it d3-esque
    legendHeight = "12px"
    legendSvgWidth = matrixProps.width + matrixProps.margin.left + matrixProps.margin.right
    legendWidth = matrixProps.width + matrixProps.margin.left + matrixProps.margin.right - 13

    makeNice = (num) -> if num > 10 then 10*(Math.floor(num/10)) else num

    getTicks = (domain) ->
      [minVal, midVal, maxVal] = domain
      midVal = makeNice(midVal)
      maxVal = Math.round(maxVal)
      results = []
      results.push(minVal)
      results.push(midVal)

      orderOfMagnitude = maxVal.toString().length
      increment = Math.pow(10, orderOfMagnitude - 1)
      console.log orderOfMagnitude, increment
      currentIncrement = 0
      while (currentIncrement + increment) < maxVal
        currentIncrement += increment
        results.push currentIncrement
      results.push maxVal
      results


    colorScale = d3.select(@find("svg.color-scale")).attr("width", legendSvgWidth).attr("height", "30px").append("g")  #.attr("transform", "translate(" + 10+ "," + 0 + ")")
    gradient = colorScale.append("svg:linearGradient").attr("id", "gradient").attr("x1", "0%").attr("y1", "0%").attr("x2", "100%").attr("y2", "0%").attr("spreadMethod", "pad")
    colorScale.append("rect").attr("width", legendWidth).attr("height", legendHeight) # .attr("x", 20)

    ticks =  getTicks(domainArray)
    console.log "TICKS:", ticks
    for tick in ticks
      offset = tick / maxValue

      # Crudely revent overlap 

      if (offset < 0.9) or (offset is 1)
        color = fill(tick)
        gradient.append("svg:stop").attr("offset", offset).attr("stop-color", color).attr("stop-opacity", 1)
        colorScale.append("rect").attr("x", legendWidth * offset).attr("y", 0).attr("height", legendHeight).style("fill", "#222").attr("width", 1)
        colorScale.append("text").attr("x", legendWidth * offset).attr("y", "24px").attr("text-anchor", "middle").text(tick)


    # fill = d3.scale.log().domain([1, maxValue/4, maxValue/2, 3*maxValue/4, maxValue]).range(["blue", "green", "yellow", "red"])
    matrix = [] # matrix mapping countries to industries
    invMatrix = [] # matrix mapping industries to countries
    for datum in data
      countryCode = datum.countryCode
      industry = datum.industry
      count = datum.count
      countryIndex = countries.indexOf countryCode
      industryIndex = industries.indexOf industry
      normalizedCount = count
      matrix[countryIndex] ?= d3.range(industries.length).map (j) ->
        x: j
        y: countryIndex
        z: 0
      invMatrix[industryIndex] ?= d3.range(countries.length).map (j) ->
        x: industryIndex
        y: j
        z: 0
      matrix[countryIndex][industryIndex].z += normalizedCount
      invMatrix[industryIndex][countryIndex].z += normalizedCount
    # Country and Industry Ordering
    countryOrders =
      name: d3.range(countries.length).sort((a, b) ->
        d3.ascending countries[a], countries[b]
      )
      count: d3.range(countries.length).sort((a, b) ->
        d3.ascending countryCounts[countries[b]], countryCounts[countries[a]]
      )
    industryOrders =
      name: d3.range(industries.length).sort((a, b) ->
        d3.ascending industries[a], industries[b]
      )
      count: d3.range(industries.length).sort((a, b) ->
        d3.descending industryCounts[industries[a]], industryCounts[industries[b]]
      )
     countryOrder = (value) ->
      matrixScales.x.domain countryOrders[value]
      t = svg.transition().duration(300)

      t.selectAll(".row").delay((d, i) ->
        matrixScales.x(i) * 1
      ).attr "transform", (d, i) ->
        "translate(0," + matrixScales.x(i) + ")"

      t.selectAll(".column").delay((d, i) ->
        matrixScales.x(i) * 1
      ).attr("transform", (d, i) ->
        "translate(" + matrixScales.y(i) + ")rotate(-90)"
      ).selectAll(".cell").delay((d) ->
        matrixScales.x d.x
      ).attr "x", (d) ->
        -matrixScales.x(d.y) - matrixScales.x.rangeBand()

    industryOrder = (value) ->
      matrixScales.y.domain industryOrders[value]
      t = svg.transition().duration(300)

      t.selectAll(".row").delay((d, i) ->
        matrixScales.x(i) * 1
      ).attr "transform", (d, i) ->
        "translate(0," + matrixScales.x(i) + ")"

      t.selectAll(".column").delay((d, i) ->
        matrixScales.x(i) * 1
      ).attr("transform", (d, i) ->
        "translate(" + matrixScales.y(i) + ")rotate(-90)"
      ).selectAll(".cell").delay((d) ->
        matrixScales.x d.x
      ).attr "x", (d) ->
        -matrixScales.x(d.y) - matrixScales.x.rangeBand()

      # TODO Ensure that this matches the initial setup
      t_header = header_svg.transition().duration(300)
      t_header.selectAll(".column-title text").delay((d, i) ->
        matrixScales.x(i) * 1
      ).attr("transform", (d, i) ->
        "translate(" + matrixScales.y(i) + ")rotate(-90)"
      )
    # Rows
    updateRows = (matrix) ->
      # DATA JOIN
      row = svg.selectAll(".row").data(matrix, (d, i) -> # Pass in index, bind country name from sorted countries list
        countries[i]
      )
      # UPDATE
      # row.attr("class", "update");
      # ENTER
      g = row.enter().append("g").attr("class", "row")
      row.append("line").attr "x2", matrixProps.width
      text = row.append("text").attr("class", "row-title").attr("x", -6).attr("y", matrixScales.x.rangeBand() / 2).attr("dy", ".32em").attr("text-anchor", "end").attr("font-family", "Lato").attr("fill", "#222222").attr("font-weight", "bold").attr("font-size", "0.8em")
      # ENTER + Update
      g.attr "transform", (d, i) ->
        "translate(0," + matrixScales.x(i) + ")"
      text.text (d, i) ->
        countries[i]
      # EXIT
      row.exit().attr("class", "exit").transition().duration(750).attr("y", 60).remove()
    updateColumns = (invMatrix) ->
      # Cells
      column = (column) ->
        # ENTER
        cell = d3.select(this).selectAll(".cell").data(column.filter((d) -> d.z))
        rect = cell.enter().append("rect").attr("class", "cell").attr("x", (d) ->
          -matrixScales.x(d.y) - matrixScales.x.rangeBand()
        ).attr("width", (Math.round(matrixScales.x.rangeBand() * 10) / 10) - 0.1).attr("height", (Math.round(matrixScales.y.rangeBand() * 10) / 10) - 0.5).on("mousemove", mouseover).on("mouseout", mouseout).on("click", clickevent)
        # ENTER + UPDATE
        rect.style "fill", (d) -> 
          # console.log fill.domain(), d.z, fill(d.z)
          fill d.z
        # EXIT
        cell.exit().attr("class", "exit").transition().duration(750).attr("y", 60).remove()
      columns = svg.selectAll(".column").data(invMatrix)
      columnTitles = header_svg.selectAll(".column-title").data(invMatrix)
      g = columns.enter().append("g").attr("class", "column")
      g.attr("transform", (d, i) ->
        "translate(" + matrixScales.y(i) + ")rotate(-90)"
      ).each column
      gColumnTitles = columnTitles.enter().append("g").attr("class", "column-title")
      text = gColumnTitles.append("text")
        .attr("dy", ".32em")
        .attr("text-anchor", "start")
        .attr("font-family", "Lato")
        .attr("font-size", "1.2em")
        .attr("fill", "#222222")
        .attr("x", 6)
        .attr("y", matrixScales.y.rangeBand() / 2)
      text.text (d, i) ->
        industries[i].capitalize()
      text.attr "transform", (d, i) ->
        "translate(" + matrixScales.y(i) + ")rotate(-90)"
      columns.exit().attr "class", "exit"

    Deps.autorun -> countryOrder Session.get "countryOrder"
    Deps.autorun -> industryOrder Session.get "industryOrder"
    updateRows matrix
    updateColumns invMatrix

    # 
    # Legend
    #     
    # TODO Make sure this works
   