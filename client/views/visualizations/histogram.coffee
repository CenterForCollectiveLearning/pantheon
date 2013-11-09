# http://bl.ocks.org/mbostock/3885705

histogramProps = 
    width: 725
    height: 560
    margin:
        top: 10
        right: 10
        bottom: 5
        left: 30

Template.matrix_svg.properties = 
    fullWidth: histogramProps.width + histogramProps.margin.left + histogramProps.margin.right
    fullHeight: histogramProps.height + histogramProps.margin.top + histogramProps.margin.bottom

Template.histogram_svg.properties = histogramProps

Template.histogram_svg.rendered = ->
    context = this

    # Visualization Parameters and Objects
    histogramProps.fullWidth = $(".page-middle").width()
    histogramProps.width = histogramProps.fullWidth - histogramProps.margin.left - histogramProps.margin.right

    formatPercent = d3.format(".0%")
    x = d3.scale.ordinal().rangeRoundBands([0, histogramProps.width], .1, 1)
    y = d3.scale.linear().range([histogramProps.height, 0])
    xAxis = d3.svg.axis().scale(x).orient("bottom")
    yAxis = d3.svg.axis().scale(y).orient("left").tickFormat(formatPercent)
    console.log histogramProps
    svg = d3.select(@find("svg.histogram"))
        .attr("width", histogramProps.fullWidth)
        .attr("height", histogramProps.fullHeight)
      .append("g")
        .attr("transform", "translate(" + histogramProps.margin.left + "," + 0 + ")")
    change = -> 
        clearTimeout sortTimeout

    data = Histogram.find().fetch()

    # TODO Make this correct
    # Copy-on-write since tweens are evaluated after a delay.
    # x0 = x.domain(data.sort((if @checked then (a, b) ->
    #     b.rca - a.rca
    #     else (a, b) ->
    #         d3.ascending a.industry, b.industry
    #         )).map((d) ->
    #     d.industry
    # )).copy()

    transition = svg.transition().duration(750)
    delay = (d, i) -> i * 50

    # transition.selectAll(".bar").delay(delay).attr "x", (d) -> x0 d.industry

    transition.select(".x.axis").call(xAxis).selectAll("g").delay delay

    x.domain data.map (d) -> d.industry
    y.domain [0, d3.max(data, (d) -> d.rca)]

    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + histogramProps.height + ")")
        .call(xAxis)
    
    svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
      .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("Frequency")

    svg.selectAll(".bar")
        .data(data)
      .enter().append("rect")
        .attr("class", "bar")
        .attr("x", (d) -> x d.industry)
        .attr("width", x.rangeBand()).attr("y", (d) -> y d.rca)
        .attr("height", (d) -> histogramProps.height - y(d.rca))

  # d3.select("input").on "change", change
  # sortTimeout = setTimeout(->
  #   d3.select("input").property("checked", true).each change
  # , 2000)