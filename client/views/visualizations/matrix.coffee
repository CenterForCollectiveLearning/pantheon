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

  # TODO Don't rerun this code on every render
  fill = d3.scale.linear().domain([0, 1]).range(["#f1e7d0", "red"])

  matrixScales =
    x: d3.scale.ordinal().rangeBands([0, matrixProps.height])
    y: d3.scale.ordinal().rangeBands([0, matrixProps.width])
    z: d3.scale.linear().domain([0, 1]).clamp(true)
    c: d3.scale.category10().domain(d3.range(10))

  data = Matrix.find().fetch()

  # SVG Handles 
  # TODO Add in handles
  svg = d3.select(@find("svg.matrix")).attr("width", matrixProps.fullWidth).append("g").attr("transform", "translate(" + matrixProps.margin.left + "," + 0 + ")")
  header_svg = d3.select(@find("svg.header")).attr("width", matrixProps.fullWidth).append("g").attr("transform", "translate(" + matrixProps.margin.left + "," + matrixProps.headerHeight + ")")
  
  Deps.autorun ->


    # TODO: Don't re-render tooltip for already selected cell
    mouseover = (p) ->
      console.log "MOUSEOVER"
      Session.set "hover", true
      d3.selectAll(".row text").classed "active", (d, i) ->
        i is p.y

      d3.selectAll(".column-title").classed "active", (d, i) ->
        i is p.x

      # Positioning
      position =
        left: (d3.event.pageX + 40)
        top: (d3.event.pageY - 45)

      Session.set "tooltipPosition", position
      countryCode = countries[p.y]
      countryName = Countries.findOne(countryCode: countryCode).countryName

      console.log countryCode, countryName
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
      Session.set "showTooltip", false
      $("#tooltip").empty()
      d3.selectAll("text").classed "active", false
    
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
      text = row.append("text").attr("class", "row-title").attr("x", -6).attr("y", matrixScales.x.rangeBand() / 2).attr("dy", ".32em").attr("text-anchor", "end").attr("font-family", "Lato").attr("fill", "#ffffff").attr("font-weight", "lighter").attr("font-size", "0.8em")
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
        cell = d3.select(this).selectAll(".cell").data(column.filter((d) ->
          d.z
        ))
        rect = cell.enter().append("rect").attr("class", "cell").attr("x", (d) ->
          -matrixScales.x(d.y) - matrixScales.x.rangeBand()
        ).attr("width", (Math.round(matrixScales.x.rangeBand() * 10) / 10) - 0.1).attr("height", (Math.round(matrixScales.y.rangeBand() * 10) / 10) - 0.5).on("mousemove", mouseover).on("mouseout", mouseout)
        
        # ENTER + UPDATE
        rect.style "fill", (d) ->
          fill d.z

        # EXIT
        cell.exit().attr("class", "exit").transition().duration(750).attr("y", 60).remove()

      columns = svg.selectAll(".column").data(invMatrix)
      columnTitles = header_svg.selectAll(".column-title").data(invMatrix)
      g = columns.enter().append("g").attr("class", "column")
      text = columnTitles.enter().append("text").attr("class", "column-title").attr("dy", ".32em").attr("text-anchor", "start").attr("font-family", "Lato").attr("font-size", "1.2em").attr("fill", "#ffffff").attr("font-weight", "lighter").attr("x", 6).attr("y", matrixScales.y.rangeBand() / 2)
      g.attr("transform", (d, i) ->
        "translate(" + matrixScales.y(i) + ")rotate(-90)"
      ).each column
      text.text (d, i) ->
        industries[i].capitalize()

      text.attr "transform", (d, i) ->
        "translate(" + matrixScales.y(i) + ")rotate(-90)"

      columns.exit().attr "class", "exit"

    countries = [] 
    industries = []
    maxValues = {}
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
  
      maxValues[countryCode] ?= 0
      if count > maxValues[countryCode] then maxValues[countryCode] = count

    matrix = [] # matrix mapping countries to industries
    invMatrix = [] # matrix mapping industries to countries
    for datum in data
      countryCode = datum.countryCode
      industry = datum.industry
      count = datum.count

      countryIndex = countries.indexOf countryCode
      industryIndex = industries.indexOf industry
      normalizedCount = count / maxValues[countryCode]

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


    countryOrder Session.get "countryOrder"
    industryOrder Session.get "industryOrder"
    updateRows matrix
    updateColumns invMatrix
  
  # 
  # Legend
  #     
  # TODO Make sure this works
  colorScale = d3.select(@find("svg.color-scale")).attr("width", matrixProps.width + matrixProps.margin.left + matrixProps.margin.right).attr("height", "30px")
  gradient = colorScale.append("svg:linearGradient").attr("id", "gradient").attr("x1", "0%").attr("y1", "0%").attr("x2", "100%").attr("y2", "0%").attr("spreadMethod", "pad")
  gradient.append("svg:stop").attr("offset", "0%").attr("stop-color", "#f1e7d0").attr "stop-opacity", 1
  gradient.append("svg:stop").attr("offset", "100%").attr("stop-color", "red").attr "stop-opacity", 1
  colorScale.append("rect").attr("width", matrixProps.width + matrixProps.margin.left + matrixProps.margin.right).attr "height", "30px"
  colorScale.append("text").attr("x", 5).attr("y", "21px").text "0%"
  colorScale.append("text").attr("x", matrixProps.width / 4).attr("y", "21px").text "25%"
  colorScale.append("text").attr("x", matrixProps.width / 2).attr("y", "21px").text "50%"
  colorScale.append("text").attr("x", 3 * matrixProps.width / 4).attr("y", "21px").text "75%"
  colorScale.append("text").attr("x", matrixProps.width - 5).attr("y", "21px").text "100%"