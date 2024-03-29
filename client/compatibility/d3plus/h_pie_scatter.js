
d3plus.pie_scatter = function(vars) {
  
  var covered = false
  
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  // Define size scaling
  //-------------------------------------------------------------------
  if (!vars.data) vars.data = []
  var size_domain = d3.extent(vars.data, function(d){ 
    return d[vars.value_var] == 0 ? null : d[vars.value_var] 
  })
  
  if (!size_domain[1]) size_domain = [0,0]
  
  var max_size = d3.max([d3.min([vars.graph.width,vars.graph.height])/15,10]),
      min_size = 10
      
  if (size_domain[0] == size_domain[1]) var min_size = max_size
  
  var size_range = [min_size,max_size]
  
  vars.size_scale = d3.scale[vars.size_scale_type]()
    .domain(size_domain)
    .range(size_range)
    
  //===================================================================
  
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  // Graph setup
  //-------------------------------------------------------------------
  
  // Create Axes
  vars.x_scale = d3.scale[vars.xscale_type]()
    .clamp(true)
    .domain([0.1, vars.xaxis_domain[1]])
    .range([0, vars.graph.width])
    .nice()
  
  vars.y_scale = d3.scale[vars.yscale_type]()
    .clamp(true)
    .domain([vars.yaxis_domain[0], 0.1])
    .range([0, vars.graph.height])
    .nice()

  if (vars.xscale_type != "log") set_buffer("x")
  if (vars.yscale_type != "log") set_buffer("y")
  
  // set buffer room (take into account largest size var)
  function set_buffer(axis) {
    
    var scale = vars[axis+"_scale"]
    var inverse_scale = d3.scale[vars[axis+"scale_type"]]()
      .domain(scale.range())
      .range(scale.domain())
      
    var largest_size = vars.size_scale.range()[1]

    // convert largest size to x scale domain
    largest_size = inverse_scale(largest_size)
    
    // get radius of largest in pixels by subtracting this value from the x scale minimum
    var buffer = largest_size - scale.domain()[0];

    // update x scale with new buffer offsets
    vars[axis+"_scale"]
      .domain([scale.domain()[0]-buffer,scale.domain()[1]+buffer])
  }
  
  graph_update();
  
  //===================================================================
  
  
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  // NODES
  //-------------------------------------------------------------------
  
  var arc = d3.svg.arc()
    .innerRadius(0)
    .startAngle(0)
    .outerRadius(function(d) { return d.arc_radius })
    .endAngle(function(d) { return d.arc_angle })
  
  // sort nodes so that smallest are always on top"
  vars.data.sort(function(node_a, node_b){
    return node_b[vars.value_var] - node_a[vars.value_var];
  })
  
  vars.chart_enter.append("g").attr("class","circles")
  
  var nodes = d3.select("g.circles").selectAll("g.circle")
    .data(vars.data,function(d){ return d[vars.id_var] })
  
  nodes.enter().append("g")
    .attr("opacity", 0)
    .attr("class", "circle")
    .attr("transform", function(d) { return "translate("+vars.x_scale(d[vars.xaxis_var])+","+vars.y_scale(d[vars.yaxis_var])+")" } )
    .each(function(d){
      
      d3.select(this)
        .append("circle")
        .style("stroke", function(dd){
          if (d[vars.active_var] || (d.num_children_active == d.num_children && d[vars.active_var] != false)) {
            return "#333";
          }
          else {
            return find_color(d[vars.id_var]);
          }
        })
        .style('stroke-width', 1)
        .style('fill', function(dd){
          if (d[vars.active_var] || (d.num_children_active == d.num_children && d[vars.active_var] != false)) {
            return find_color(d[vars.id_var]);
          }
          else {
            var c = d3.hsl(find_color(d[vars.id_var]));
            c.l = 0.95;
            return c.toString();
          }
        })
        .attr("r", 0 )
        
      vars.arc_angles[d.id] = 0
      vars.arc_sizes[d.id] = 0
        
      d3.select(this)
        .append("path")
        .attr("class", "circle")
        .style('fill', find_color(d[vars.id_var]) )
        .style("fill-opacity", 1)
        
      d3.select(this).select("path").transition().duration(d3plus.timing)
        .attrTween("d",arcTween)
        
    })

  
  // update

  onMouseOver = function(d){
      Session.set("hover", true);
      
      var val = d[vars.value_var] ? d[vars.value_var] : vars.size_scale.domain()[0]
      var radius = 9, // CHANGED vars.size_scale(val),
          x = vars.x_scale(d[vars.xaxis_var]),
          y = vars.y_scale(d[vars.yaxis_var]),
          color = d[vars.active_var] || d.num_children_active/d.num_children == 1 ? "#333" : find_color(d[vars.id_var]),
          viz = d3.select("g.chart");

      var dataPoint = d.id;
      var xVar = vars.xaxis_var;
      var yVar = vars.yaxis_var;

      var vizMode = Session.get("vizMode");

      // Positioning
      var position = {
        "left": (d3.event.clientX + 40),
        "top": (d3.event.clientY - 45)
      }
      Session.set("tooltipPosition", position);
   
      // Subscription Parameters
      if (vizMode === 'country_vs_country') {
        var countryCodeX = xVar; // Countries.findOne({countryName: xVar}).countryCode;
        var countryCodeY = yVar; // Countries.findOne({countryName: yVar}).countryCode;
        var category = dataPoint;
        var categoryLevel = "occupation";

        Session.set("tooltipCategory", category);
        Session.set("tooltipCategoryLevel", categoryLevel);
        Session.set("tooltipCountryCodeX", countryCodeX);
        Session.set("tooltipCountryCodeY", countryCodeY);
        Template.tooltip.heading = dataPoint;
        Template.mobile_tooltip_ranking.heading = dataPoint;
      } else if (vizMode === 'domain_vs_domain') {
        countryName = Countries.findOne({countryCode: dataPoint}).countryName;
        Session.set("tooltipCountryCode", dataPoint);

        Session.set("tooltipCategoryLevelX", Session.get("categoryLevelX"));
        Session.set("tooltipCategoryLevelY", Session.get("categoryLevelY"));
        Session.set("tooltipCategoryX", xVar);
        Session.set("tooltipCategoryY", yVar);
        Template.tooltip.heading = countryName;
        Template.mobile_tooltip_ranking.heading = countryName;
      }

      Session.set("showTooltip", true);

      if(Session.get("mobile")) {
        d3.selectAll(".axis_hover").remove();
      }

      // vertical line to x-axis
      viz.append("line")
        .attr("class", "axis_hover")
        .attr("x1", x)
        .attr("x2", x)
        .attr("y1", y+radius+1) // offset so hover doens't flicker
        .attr("y2", vars.graph.height)
        .attr("stroke", color)
        .attr("stroke-width", 1)
        .attr("shape-rendering","crispEdges")
    
      // horizontal line to y-axis
      viz.append("line")
        .attr("class", "axis_hover")
        .attr("x1", 0)
        .attr("x2", x-radius) // offset so hover doens't flicker
        .attr("y1", y)
        .attr("y2", y)
        .attr("stroke", color)
        .attr("stroke-width", 1)
        .attr("shape-rendering","crispEdges")
    
      // x-axis value box
      var xrect = viz.append("rect")
        .attr("class", "axis_hover")
        .attr("y", vars.graph.height)
        .attr("height", 20)
        .attr("fill", "white")
        .attr("stroke", color)
        .attr("stroke-width", 1)
        .attr("shape-rendering","crispEdges")
    
      var xtext = vars.number_format(d[vars.xaxis_var],vars.xaxis_var)
      
      // xvalue text element
      var xtext = viz.append("text")
        .attr("class", "axis_hover")
        .attr("x", x)
        .attr("y", vars.graph.height)
        .attr("dy", 14)
        .attr("text-anchor","middle")
        .style("font-weight",vars.font_weight)
        .attr("font-size","12px")
        .attr("font-family",vars.font)
        .attr("fill","#4c4c4c")
        .text(xtext)
        
      var xwidth = xtext.node().getBBox().width+10
      xrect.attr("width",xwidth)
        .attr("x",x-(xwidth/2))
    
      // y-axis value box
      var yrect = viz.append("rect")
        .attr("class", "axis_hover")
        .attr("y", y-10)
        .attr("height", 20)
        .attr("fill", "white")
        .attr("stroke", color)
        .attr("stroke-width", 1)
        .attr("shape-rendering","crispEdges")
      
      var ytext = vars.number_format(d[vars.yaxis_var],vars.yaxis_var)
      
      // xvalue text element
      var ytext = viz.append("text")
        .attr("class", "axis_hover")
        .attr("x", -25)
        .attr("y", y-10)
        .attr("dy", 14)
        .attr("text-anchor","middle")
        .style("font-weight",vars.font_weight)
        .attr("font-size","12px")
        .attr("font-family",vars.font)
        .attr("fill","#4c4c4c")
        .text(ytext)

      var ywidth = ytext.node().getBBox().width+10
      ytext.attr("x",-ywidth/2)
      yrect.attr("width",ywidth)
        .attr("x",-ywidth)
        
      var ex = null
      if (d.num_children > 1 && !vars.spotlight && d.num_children_active != d.num_children) {
        var num = d.num_children_active,
            den = d.num_children
        ex = {"fill":num+"/"+den+" ("+vars.number_format((num/den)*100,"share")+"%)"}
      }
      var tooltip_data = get_tooltip_data(d,"short",ex)
    }

  onMouseOut = function(d){
      Session.set("hover", false);
      Session.set("showTooltip", false);
      $("#tooltip").empty();

      d3.selectAll(".axis_hover").remove()
    }

  onClick = function(d){
      // On click show clicktooltip overlay
      Session.set("hover", false);
      Session.set("showTooltip", false);
      if (Session.equals("tutorialType", null) || Session.equals("tutorialType", undefined)) {
        var dataPoint = d.id;
        var xVar = vars.xaxis_var;
        var yVar = vars.yaxis_var;

        var dataset = Session.get("dataset");
        var vizMode = Session.get("vizMode");

        // Positioning
        var position = {
            "left": (d3.event.clientX + 40),
            "top": (d3.event.clientY - 45)
        }
        Session.set("tooltipPosition", position);

        // Subscription Parameters
        if (vizMode === 'country_vs_country') {
            var countryCodeX = xVar;
            var countryCodeY = yVar;
            var category = dataPoint;
            var categoryLevel = "occupation";

            Session.set("bigtooltipCategory", category);
            Session.set("bigtooltipCategoryLevel", categoryLevel);
            Session.set("bigtooltipCountryCodeX", countryCodeX);
            Session.set("bigtooltipCountryCodeY", countryCodeY);
            Template.clicktooltip.title = dataPoint;
        } else if (vizMode === 'domain_vs_domain') {
            Session.set("bigtooltipCountryCode", dataPoint);
            countryName = Countries.findOne({countryCode: dataPoint, dataset: dataset}).countryName
            Session.set("bigtooltipCategoryLevel", Session.get("categoryLevel"));
            Session.set("bigtooltipCategoryLevelX", Session.get("categoryLevelX"));
            Session.set("bigtooltipCategoryLevelY", Session.get("categoryLevelY"));
            Session.set("bigtooltipCategoryX", xVar);
            Session.set("bigtooltipCategoryY", yVar);
            Template.clicktooltip.title = countryName;
        }
        // Set the session variable to show the clicktooltip
        Session.set("clicktooltip", true);
      }
    }
  
  nodes
    .on(d3plus.evt.over, function(d) { if(!Session.get("mobile")) onMouseOver(d) })
    .on(d3plus.evt.out, function(d) { if(!Session.get("mobile")) onMouseOut(d) })
    .on(d3plus.evt.click, function(d) {
      if(Session.get("mobile")) onMouseOver(d)
      else onClick(d)
    });
    
  nodes.transition().duration(d3plus.timing)
    .attr("transform", function(d) { return "translate("+vars.x_scale(d[vars.xaxis_var])+","+vars.y_scale(d[vars.yaxis_var])+")" } )
    .attr("opacity", 1)
    .each(function(d){

      var val = d[vars.value_var]
      val = val && val > 0 ? val : vars.size_scale.domain()[0]
      d.arc_radius = 9; // vars.size_scale(val);
      
      d3.select(this).select("circle").transition().duration(d3plus.timing)
        .style("stroke", function(dd){
          if (d[vars.active_var] || (d.num_children_active == d.num_children && d[vars.active_var] != false)) return "#333";
          else return find_color(d[vars.id_var]);
        })
        .style('fill', function(dd){
          if (d[vars.active_var] || (d.num_children_active == d.num_children && d[vars.active_var] != false)) return find_color(d[vars.id_var]);
          else {
            var c = d3.hsl(find_color(d[vars.id_var]));
            c.l = 0.95;
            return c.toString();
          }
        })
        .attr("r", d.arc_radius )

      
      if (d.num_children) {
        d.arc_angle = (((d.num_children_active / d.num_children)*360) * (Math.PI/180));
        d3.select(this).select("path").transition().duration(d3plus.timing)
          .style('fill', find_color(d[vars.id_var]) )
          .attrTween("d",arcTween)
          .each("end", function(dd) {
            vars.arc_angles[d.id] = d.arc_angle
            vars.arc_sizes[d.id] = d.arc_radius
          })
      }
      
    })
  
  // exit
  nodes.exit()
    .transition().duration(d3plus.timing)
    .attr("opacity", 0)
    .remove()
  
  //===================================================================
  
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  // Data Ticks
  //-------------------------------------------------------------------
  
  var tick_group = vars.chart_enter.append("g")
    .attr("id","data_ticks")
  
  var ticks = d3.select("g#data_ticks")
    .selectAll("g.data_tick")
    .data(vars.data, function(d){ return d[vars.id_var]; })
  
  var ticks_enter = ticks.enter().append("g")
    .attr("class", "data_tick")
  
  // y ticks
  // ENTER
  ticks_enter.append("line")
    .attr("class", "ytick")
    .attr("x1", -10)
    .attr("x2", 0)
    .attr("y1", function(d){ return vars.y_scale(d[vars.yaxis_var]) })
    .attr("y2", function(d){ return vars.y_scale(d[vars.yaxis_var]) })
    .attr("stroke", function(d){ return find_color(d[vars.id_var]); })
    .attr("stroke-width", 1)
    .attr("shape-rendering","crispEdges")
  
  // UPDATE      
  ticks.select(".ytick").transition().duration(d3plus.timing)
    .attr("x1", -10)
    .attr("x2", 0)
    .attr("y1", function(d){ return vars.y_scale(d[vars.yaxis_var]) })
    .attr("y2", function(d){ return vars.y_scale(d[vars.yaxis_var]) })
  
  // x ticks
  // ENTER
  ticks_enter.append("line")
    .attr("class", "xtick")
    .attr("y1", vars.graph.height)
    .attr("y2", vars.graph.height + 10)      
    .attr("x1", function(d){ return vars.x_scale(d[vars.xaxis_var]) })
    .attr("x2", function(d){ return vars.x_scale(d[vars.xaxis_var]) })
    .attr("stroke", function(d){ return find_color(d[vars.id_var]); })
    .attr("stroke-width", 1)
    .attr("shape-rendering","crispEdges")
  
  // UPDATE
  ticks.select(".xtick").transition().duration(d3plus.timing)
    .attr("y1", vars.graph.height)
    .attr("y2", vars.graph.height + 10)      
    .attr("x1", function(d){ return vars.x_scale(d[vars.xaxis_var]) })
    .attr("x2", function(d){ return vars.x_scale(d[vars.xaxis_var]) })
  
  // EXIT (needed for when things are filtered/soloed)
  ticks.exit().remove()
  
  //===================================================================
  
  function arcTween(b) {
    var i = d3.interpolate({arc_angle: vars.arc_angles[b.id], arc_radius: vars.arc_sizes[b.id]}, b);
    return function(t) {
      return arc(i(t));
    };
  }
  
};
