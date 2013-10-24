# Utility Functions
aggregate = (obj, values, context) ->
  return obj  unless values.length
  byFirst = _.groupBy(obj, values[0], context)
  rest = values.slice(1)
  for prop of byFirst
    byFirst[prop] = aggregate(byFirst[prop], rest, context)
  byFirst


# Aggregate to bottom level, then sum
aggregateCounts = (obj, values, context) ->
  return obj.length  unless values.length
  byFirst = _.groupBy(obj, values[0], context)
  rest = values.slice(1)
  for prop of byFirst
    byFirst[prop] = aggregateCounts(byFirst[prop], rest, context)
  byFirst


# TODO put this function somewhere like a library, not randomly in this code.
String::capitalize = ->
  
  # Match letters at beginning of string or after white space character
  @toLowerCase().replace /(?:^|\s)\S/g, (a) ->
    a.toUpperCase()



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
  timing = 600
  
  # TODO Don't rerender if already rendered
  # if ( this.rendered ) {
  #     console.log("RENDERED", this.rendered);
  #     return;
  # }
  # this.rendered = true;
  
  # Visualization width (NOT SVG width)
  matrixProps.fullWidth = $(".page-middle").width()
  matrixProps.width = matrixProps.fullWidth - matrixProps.margin.left - matrixProps.margin.right
  fill = d3.scale.linear().domain([0, 1]).range(["#f1e7d0", "red"])
  matrixScales =
    x: d3.scale.ordinal().rangeBands([0, matrixProps.height])
    y: d3.scale.ordinal().rangeBands([0, matrixProps.width])
    z: d3.scale.linear().domain([0, 1]).clamp(true)
    c: d3.scale.category10().domain(d3.range(10))

  data = Matrix.find().fetch()
  
  # SVG Handles 
  svg = d3.select(@find("svg.matrix")).attr("width", matrixProps.fullWidth).append("g").attr("transform", "translate(" + matrixProps.margin.left + "," + 0 + ")")
  header_svg = d3.select(@find("svg.header")).attr("width", matrixProps.fullWidth).append("g").attr("transform", "translate(" + matrixProps.margin.left + "," + matrixProps.headerHeight + ")")
  svg.transition().duration(timing).attr "width", matrixProps.fullWidth
  header_svg.transition().duration timing
  
  # Initializing Data Containers 
  matrix = [] # matrix mapping countries to industries
  inv_matrix = [] # matrix mapping industries to countries
  industries = [] # entities on x-axis (list of industries)
  countries = [] # entities on y-axis (list of countries)
  links = [] # list of {industry, country, value}
  min_values = {} # keyed by country
  max_values = {} # keyed by country
  fills = {} # keyed by country
  country_counts = {}
  industry_counts = {}
  input = aggregateCounts(data, ["countryCode", "industry", "gender"])
  grouped_individuals = aggregate(data, ["countryCode", "industry"])
  Deps.autorun ->
    
    # Populate matrix
    
    # Populate inverted matrix
    
    # Convert links to matrix.
    
    # Precompute ordering
    
    # Rows
    # Recompute mapping from country to element and y position of element
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
    
    # TODO be clear what you want
    updateColumns = (inv_matrix) ->
      
      # DATA JOIN
      
      # UPDATE
      # columns.attr("class", "update");
      
      # ENTER
      
      # ENTER + UPDATE
      
      # EXIT
      
      # .transition()
      # .duration(750)
      # .attr("y", 60)
      # .remove();
      
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
      columns = svg.selectAll(".column").data(inv_matrix)
      columnTitles = header_svg.selectAll(".column-title").data(inv_matrix)
      g = columns.enter().append("g").attr("class", "column")
      text = columnTitles.enter().append("text").attr("class", "column-title").attr("dy", ".32em").attr("text-anchor", "start").attr("font-family", "Lato").attr("font-size", "1.2em").attr("fill", "#ffffff").attr("font-weight", "lighter").attr("x", 6).attr("y", matrixScales.y.rangeBand() / 2)
      g.attr("transform", (d, i) ->
        "translate(" + matrixScales.y(i) + ")rotate(-90)"
      ).each column
      text.text (d, i) ->
        industries[i].capitalize()

      text.attr "transform", (d, i) ->
        "translate(" + matrixScales.y(i) + ")rotate(-90)"

      console.log "EXIT", columns.exit()
      columns.exit().attr "class", "exit"
    createTooltip = (categoryA, categoryB) ->
    destroyTooltip = (mouseoverElement) ->
      Template.tooltip.top5 = null
      Session.set "showTooltip", false
      $("#tooltip").empty()
    
    # mouseoverElement = null;
    
    # TODO: Don't re-render tooltip for already selected cell
    mouseover = (p) ->
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
      Session.set "hover", false
      destroyTooltip p
      d3.selectAll("text").classed "active", false
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

    gender = Session.get("gender")
    from = Session.get("from")
    to = Session.get("to")
    langs = Session.get("langs")
    console.log "GENDER", gender
    console.log input
    for countryCode of input
      for industry of input[countryCode]
        f_res = (if (not isNaN(input[countryCode][industry]["Female"])) then input[countryCode][industry]["Female"] else 0)
        m_res = (if (not isNaN(input[countryCode][industry]["Male"])) then input[countryCode][industry]["Male"] else 0)
        results =
          both: f_res + m_res
          male: m_res
          female: f_res
          ratio: (if ((f_res / m_res) is Number.POSITIVE_INFINITY) then 1 else f_res / m_res)

        value = results[gender]
        links.push
          country: countryCode
          industry: industry
          value: value

        industries.push industry  if industries.indexOf(industry) is -1
        if countries.indexOf(countryCode) is -1
          countries.push countryCode
          min_values[countryCode] = Number.MAX_VALUE
          max_values[countryCode] = Number.MIN_VALUE
        if value < min_values[countryCode]
          min_values[countryCode] = value
        else max_values[countryCode] = value  if value > max_values[countryCode]
    country_count = countries.length
    industry_count = industries.length
    countries.forEach (country, i) ->
      country_counts[i] = 0
      matrix[i] = d3.range(industry_count).map((j) ->
        x: j
        y: i
        z: 0
      )

    industries.forEach (industry, i) ->
      industry_counts[i] = 0
      inv_matrix[i] = d3.range(country_count).map((j) ->
        x: i
        y: j
        z: 0
      )

    links.forEach (link) ->
      country = link["country"]
      industry = link["industry"]
      country_index = countries.indexOf(country)
      industry_index = industries.indexOf(industry)
      value = link["value"] / max_values[country]
      max_values[country] is Number.MIN_VALUE
      country_counts[country_index] += 1
      industry_counts[industry_index] += 1
      matrix[country_index][industry_index].z += value
      inv_matrix[industry_index][country_index].z += value

    countryOrders =
      name: d3.range(country_count).sort((a, b) ->
        d3.ascending countries[a], countries[b]
      )
      count: d3.range(country_count).sort((a, b) ->
        d3.ascending country_counts[b], country_counts[a]
      )

    industryOrders =
      name: d3.range(industry_count).sort((a, b) ->
        d3.ascending industries[a], industries[b]
      )
      count: d3.range(industry_count).sort((a, b) ->
        d3.descending industry_counts[a], industry_counts[b]
      )

    countryOrder_var = Session.get("countryOrder")
    industryOrder_var = Session.get("industryOrder")
    countryOrder countryOrder_var
    industryOrder industryOrder_var
    updateRows matrix
    updateColumns inv_matrix

  
  # 
  #     * Legend
  #     
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