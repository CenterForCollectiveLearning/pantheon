
d3plus.stacked = function(vars) {
  
  var covered = false

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  // Helper function used to create stack polygon
  //-------------------------------------------------------------------
  
  var stack = d3.layout.stack()
    .values(function(d) { return d.values; })
    .x(function(d) { return d[vars.year_var]; })
    .y(function(d) { return d[vars.yaxis_var]; });
  
  //===================================================================
      
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  // INIT vars & data munging
  //-------------------------------------------------------------------
  
  // get max total for sums of each xaxis
  if (!vars.data) vars.data = []
  
  var xaxis_sums = d3.nest()
    .key(function(d){return d[vars.xaxis_var] })
    .rollup(function(leaves){
      return d3.sum(leaves, function(d){return d[vars.yaxis_var];})
    })
    .entries(vars.data)

  // nest data properly according to nesting array
  var nested_data = nest_data();

  var data_max = vars.layout == "share" ? 1 : d3.max(xaxis_sums, function(d){ return d.values; });

  // scales for both X and Y values
  var year_extent = vars.year instanceof Array ? vars.year : d3.extent(vars.years)
  
  vars.x_scale = d3.scale[vars.xscale_type]()
    .domain(year_extent)
    .range([0, vars.graph.width]);
  // **WARNING reverse scale from 0 - max converts from height to 0 (inverse)
  vars.y_scale = d3.scale[vars.yscale_type]()
    .domain([0, data_max])
    .range([vars.graph.height, 0]);
    
  graph_update()
  
  // Helper function unsed to convert stack values to X, Y coords 
  var area = d3.svg.area()
    .interpolate(vars.stack_type)
    .x(function(d) { return vars.x_scale(d[vars.year_var]); })
    .y0(function(d) { return vars.y_scale(d.y0); })
    .y1(function(d) { return vars.y_scale(d.y0 + d.y)+1; });
  
  //===================================================================
  
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  // LAYERS
  //-------------------------------------------------------------------
  
  vars.chart_enter.append("clipPath")
    .attr("id","path_clipping")
    .append("rect")
      .attr("width",vars.graph.width)
      .attr("height",vars.graph.height)
  
  d3.select("#path_clipping rect").transition().duration(d3plus.timing)
    .attr("width",vars.graph.width)
    .attr("height",vars.graph.height)
    .attr("x",1)
    .attr("y",1)
  
  // Get layers from d3.stack function (gives x, y, y0 values)
  var offset = vars.layout == "value" ? "zero" : "expand";
  
  if (nested_data.length) {
    var layers = stack.offset(offset)(nested_data)
  }
  else {
    var layers = []
  }
  
  // container for layers
  vars.chart_enter.append("g").attr("class", "layers")
    .attr("clip-path","url(#path_clipping)")
    
  // give data with key function to variables to draw
  var paths = d3.select("g.layers").selectAll(".layer")
    .data(layers, function(d){ return d.key; })
  
  // ENTER
  // enter new paths, could be next level deep or up a level
  paths.enter().append("path")
    .attr("opacity", 0)
    .attr("id", function(d){
      return "path_"+d[vars.id_var]
    })
    .attr("class", "layer")
    .attr("fill", function(d){
      return find_color(d.key)
    })
    .attr("d", function(d) {
      return area(d.values);
    })
    
  small_tooltip = function(d) {
    
    covered = false

    var id = find_variable(d,vars.id_var),
        self = d3.select("#path_"+id).node()

    d3.select(self).attr("opacity",1)

    d3.selectAll("line.rule").remove();
    
    var mouse_x = d3.event.layerX-vars.graph.margin.left;
    var rev_x_scale = d3.scale.linear()
      .domain(vars.x_scale.range()).range(vars.x_scale.domain());
    var this_x = Math.round(rev_x_scale(mouse_x));
    var this_x_index = vars.years.indexOf(this_x);
    var this_value = d.values[this_x_index];
    console.log("THIS.X: " + this_x); // this is the year
    console.log("THIS.value: " + this_value.y); // this is the number of people
    // TODO: update tooltip to show values for specified years, for continents?
    
    // add dashed line at closest X position to mouse location
    d3.selectAll("line.rule").remove()
    d3.select("g.chart").append("line")
      .datum(d)
      .attr("class", "rule")
      .attr({"x1": vars.x_scale(this_x), "x2": vars.x_scale(this_x)})
      .attr({"y1": vars.y_scale(this_value.y0), "y2": vars.y_scale(this_value.y + this_value.y0)})
      .attr("stroke", "white")
      .attr("stroke-width", 1)
      .attr("stroke-opacity", 0.5)
      .attr("stroke-dasharray", "5,3")
      .attr("pointer-events","none")
    
    // tooltip
//    })
      Session.set("hover", true); // TODO: this is redundant ... but why is it not working when one is taken out???
      var id = find_variable(d,vars.id_var).replace(" ", "_"),
          self = d3.select("#path_"+id).node()
      console.log("ID:" + id);

      d3.select("#path_"+id)
          .style("cursor","pointer")
          .attr("opacity",1)

      var vizMode = Session.get("vizMode");
      if (vizMode === "country_exports") {
          console.log("GETTING TOOLTIPS");
          var countryCode = Session.get("country");
          var countryName = countryCode === "all" ? "All" : Countries.findOne({countryCode: countryCode}).countryName;
          var category = id.replace("_", " ").toUpperCase();
          var categoryLevel = "domain"; // this is hardcoded based on what the stacks are
      } else if (vizMode === "domain_exports_to") {
          var countryCode = id.replace("_", " ").toUpperCase();
          console.log("countryCode: " + countryCode)
          var countryName = countryCode === "all" ? "All" : Countries.findOne({countryCode: countryCode}).countryName;
          var category = Session.get("category").toUpperCase();
          var categoryLevel = Session.get("categoryLevel");
      }

      // Positioning
      var position = {
          "left": (d3.event.clientX + 40),
          "top": (d3.event.clientY - 45)
      }
      Session.set("tooltipPosition", position);

      // Subscription Parameters
      Session.set("tooltipCategory", category);
      Session.set("tooltipCategoryLevel", categoryLevel);
      Session.set("tooltipCountryCode", countryCode);

      Template.tooltip.heading = countryCode !== "all" ? countryName + ": " + category : category;
      // Template.tooltip.categoryA = countryName;
      // Template.tooltip.categoryB = category;

      Session.set("showTooltip", true);
  }
  
  // UPDATE
  paths
    .on(d3plus.evt.over, function(d) {
      small_tooltip(d) 
    })
    .on(d3plus.evt.move, function(d) {
      small_tooltip(d) 
    })
    .on(d3plus.evt.out, function(d){
      // remove the tooltip
      Session.set("hover", false);
      Template.tooltip.top5 = null;
      Session.set("showTooltip", false);
      $("#tooltip").empty();
      
      var id = find_variable(d,vars.id_var),
          self = d3.select("#path_"+id).node()
      
      d3.selectAll("line.rule").remove()
      d3.select(self).attr("opacity",0.85)
      
      if (!covered) {
        d3plus.tooltip.remove(vars.type)
      }
      
    })
    .on(d3plus.evt.click, function(d){
      
      covered = true
        
      var id = find_variable(d,vars.id_var)
      var self = this

      var mouse_x = d3.event.layerX-vars.graph.margin.left;
      var rev_x_scale = d3.scale.linear()
        .domain(vars.x_scale.range()).range(vars.x_scale.domain());
      var this_x = Math.round(rev_x_scale(mouse_x));
      var this_x_index = vars.years.indexOf(this_x)
      var this_value = d.values[this_x_index]
      
      make_tooltip = function(html) {
      
        d3.selectAll("line.rule").remove()
        d3plus.tooltip.remove(vars.type)
        d3.select(self).attr("opacity",0.85)
        
        var tooltip_data = get_tooltip_data(this_value,"long")
        if (vars.layout == "share") {
          var share = vars.format(this_value.y*100,"share")+"%"
          tooltip_data.push({"name": vars.format("share"), "value": share})
        }
        
        d3plus.tooltip.create({
          "title": find_variable(d[vars.id_var],vars.text_var),
          "color": find_color(d[vars.id_var]),
          "icon": find_variable(d[vars.id_var],"icon"),
          "style": vars.icon_style,
          "id": vars.type,
          "fullscreen": true,
          "html": html,
          "footer": vars.footer,
          "data": tooltip_data,
          "mouseevents": true,
          "parent": vars.parent,
          "background": vars.background
        })
        
      }
      
      var html = vars.click_function ? vars.click_function(id) : null
      
      if (typeof html == "string") make_tooltip(html)
      else if (html && html.url && html.callback) {
        d3.json(html.url,function(data){
          html = html.callback(data)
          make_tooltip(html)
        })
      }
      else if (vars.tooltip_info.long) {
        make_tooltip(html)
      }
      
    })
  
  paths.transition().duration(d3plus.timing)
    .attr("opacity", 0.85)
    .attr("fill", function(d){
      return find_color(d.key)
    })
    .attr("d", function(d) {
      return area(d.values);
    })

  // EXIT
  paths.exit()
    .transition().duration(d3plus.timing)
    .attr("opacity", 0)
    .remove()
  
  //===================================================================
  
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  // TEXT LAYERS
  //-------------------------------------------------------------------

  // filter layers to only the ones with a height larger than 6% of viz
  var text_layers = [];
  var text_height_scale = d3.scale.linear().range([0, 1]).domain([0, data_max]);

  layers.forEach(function(layer){
    // find out which is the largest
    var available_areas = layer.values.filter(function(d,i,a){
      
      var min_height = 30;
      if (i == 0) {
        return (vars.graph.height-vars.y_scale(d.y)) >= min_height 
            && (vars.graph.height-vars.y_scale(a[i+1].y)) >= min_height
            && (vars.graph.height-vars.y_scale(a[i+2].y)) >= min_height
            && vars.y_scale(d.y)-(vars.graph.height-vars.y_scale(d.y0)) < vars.y_scale(a[i+1].y0)
            && vars.y_scale(a[i+1].y)-(vars.graph.height-vars.y_scale(a[i+1].y0)) < vars.y_scale(a[i+2].y0)
            && vars.y_scale(d.y0) > vars.y_scale(a[i+1].y)-(vars.graph.height-vars.y_scale(a[i+1].y0))
            && vars.y_scale(a[i+1].y0) > vars.y_scale(a[i+2].y)-(vars.graph.height-vars.y_scale(a[i+2].y0));
      }
      else if (i == a.length-1) {
        return (vars.graph.height-vars.y_scale(d.y)) >= min_height 
            && (vars.graph.height-vars.y_scale(a[i-1].y)) >= min_height
            && (vars.graph.height-vars.y_scale(a[i-2].y)) >= min_height
            && vars.y_scale(d.y)-(vars.graph.height-vars.y_scale(d.y0)) < vars.y_scale(a[i-1].y0)
            && vars.y_scale(a[i-1].y)-(vars.graph.height-vars.y_scale(a[i-1].y0)) < vars.y_scale(a[i-2].y0)
            && vars.y_scale(d.y0) > vars.y_scale(a[i-1].y)-(vars.graph.height-vars.y_scale(a[i-1].y0))
            && vars.y_scale(a[i-1].y0) > vars.y_scale(a[i-2].y)-(vars.graph.height-vars.y_scale(a[i-2].y0));
      }
      else {
        return (vars.graph.height-vars.y_scale(d.y)) >= min_height 
            && (vars.graph.height-vars.y_scale(a[i-1].y)) >= min_height
            && (vars.graph.height-vars.y_scale(a[i+1].y)) >= min_height
            && vars.y_scale(d.y)-(vars.graph.height-vars.y_scale(d.y0)) < vars.y_scale(a[i+1].y0)
            && vars.y_scale(d.y)-(vars.graph.height-vars.y_scale(d.y0)) < vars.y_scale(a[i-1].y0)
            && vars.y_scale(d.y0) > vars.y_scale(a[i+1].y)-(vars.graph.height-vars.y_scale(a[i+1].y0))
            && vars.y_scale(d.y0) > vars.y_scale(a[i-1].y)-(vars.graph.height-vars.y_scale(a[i-1].y0));
      }
    });
    var best_area = d3.max(layer.values,function(d,i){
      if (available_areas.indexOf(d) >= 0) {
        if (i == 0) {
          return (vars.graph.height-vars.y_scale(d.y))
               + (vars.graph.height-vars.y_scale(layer.values[i+1].y))
               + (vars.graph.height-vars.y_scale(layer.values[i+2].y));
        }
        else if (i == layer.values.length-1) {
          return (vars.graph.height-vars.y_scale(d.y))
               + (vars.graph.height-vars.y_scale(layer.values[i-1].y))
               + (vars.graph.height-vars.y_scale(layer.values[i-2].y));
        }
        else {
          return (vars.graph.height-vars.y_scale(d.y))
               + (vars.graph.height-vars.y_scale(layer.values[i-1].y))
               + (vars.graph.height-vars.y_scale(layer.values[i+1].y));
        }
      } else return null;
    });
    var best_area = layer.values.filter(function(d,i,a){
      if (i == 0) {
        return (vars.graph.height-vars.y_scale(d.y))
             + (vars.graph.height-vars.y_scale(layer.values[i+1].y))
             + (vars.graph.height-vars.y_scale(layer.values[i+2].y)) == best_area;
      }
      else if (i == layer.values.length-1) {
        return (vars.graph.height-vars.y_scale(d.y))
             + (vars.graph.height-vars.y_scale(layer.values[i-1].y))
             + (vars.graph.height-vars.y_scale(layer.values[i-2].y)) == best_area;
      }
      else {
        return (vars.graph.height-vars.y_scale(d.y))
             + (vars.graph.height-vars.y_scale(layer.values[i-1].y))
             + (vars.graph.height-vars.y_scale(layer.values[i+1].y)) == best_area;
      }
    })[0]
    if (best_area) {
      layer.tallest = best_area
      text_layers.push(layer)
    }
  
  })
  // container for text layers
  vars.chart_enter.append("g").attr("class", "text_layers")

  // RESET
  var texts = d3.select("g.text_layers").selectAll(".label")
    .data([])

  // EXIT
  texts.exit().remove()

  // give data with key function to variables to draw
  var texts = d3.select("g.text_layers").selectAll(".label")
    .data(text_layers)
  
  // ENTER
  texts.enter().append("text")
    // .attr('filter', 'url(#dropShadow)')
    .attr("class", "label")
    .style("font-weight",vars.font_weight)
    .attr("font-size","18px")
    .attr("font-family",vars.font)
    .attr("dy", 6)
    .attr("opacity",0)
    .attr("pointer-events","none")
    .attr("text-anchor", function(d){
      // if first, left-align text
      if(d.tallest[vars.year_var] == vars.x_scale.domain()[0]) return "start";
      // if last, right-align text
      if(d.tallest[vars.year_var] == vars.x_scale.domain()[1]) return "end";
      // otherwise go with middle
      return "middle"
    })
    .attr("fill", function(d){
      return d3plus.utils.text_color(find_color(d[vars.id_var]))
    })
    .attr("x", function(d){
      var pad = 0;
      // if first, push it off 10 pixels from left side
      if(d.tallest[vars.year_var] == vars.x_scale.domain()[0]) pad += 10;
      // if last, push it off 10 pixels from right side
      if(d.tallest[vars.year_var] == vars.x_scale.domain()[1]) pad -= 10;
      return vars.x_scale(d.tallest[vars.year_var]) + pad;
    })
    .attr("y", function(d){
      var height = vars.graph.height - vars.y_scale(d.tallest.y);
      return vars.y_scale(d.tallest.y0 + d.tallest.y) + (height/2);
    })
    .text(function(d) {
      return find_variable(d[vars.id_var],vars.text_var)
    })
    .each(function(d){
      // set usable width to 2x the width of each x-axis tick
      var tick_width = (vars.graph.width / vars.years.length) * 2;
      // if the text box's width is larger than the tick width wrap text
      if(this.getBBox().width > tick_width){
        // first remove the current text
        d3.select(this).text("")
        // figure out the usable height for this location along x-axis
        var height = vars.graph.height-vars.y_scale(d.tallest.y)
        // wrap text WITHOUT resizing
        // d3plus.utils.wordwrap(d[nesting[nesting.length-1]], this, tick_width, height, false)
      
        d3plus.utils.wordwrap({
          "text": find_variable(d[vars.id_var],vars.text_var),
          "parent": this,
          "width": tick_width,
          "height": height,
          "resize": false
        })
      
        // reset Y to compensate for new multi-line height
        var offset = (height - this.getBBox().height) / 2;
        // top of the element's y attr
        var y_top = vars.y_scale(d.tallest.y0 + d.tallest.y);
        d3.select(this).attr("y", y_top + offset)
      }
    })
    
  // UPDATE
  texts.transition().duration(d3plus.timing)
    .attr("opacity",function(){
      if (vars.small || !vars.labels) return 0
      else return 1
    })
  
  //===================================================================
  
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  // Nest data function (needed for getting flat data ready for stacks)
  //-------------------------------------------------------------------
  
  function nest_data(){
    
    var nested = d3.nest()
      .key(function(d){ return d[vars.id_var]; })
      .rollup(function(leaves){
          
        // Make sure all xaxis_vars at least have 0 values
        var years_available = leaves
          .reduce(function(a, b){ return a.concat(b[vars.xaxis_var])}, [])
          .filter(function(y, i, arr) { return arr.indexOf(y) == i })
          
        vars.years.forEach(function(y){
          if(years_available.indexOf(y) < 0){
            var obj = {}
            obj[vars.xaxis_var] = y
            obj[vars.yaxis_var] = 0
            if (leaves[0][vars.id_var]) obj[vars.id_var] = leaves[0][vars.id_var]
            if (leaves[0][vars.text_var]) obj[vars.text_var] = leaves[0][vars.text_var]
            if (leaves[0][vars.color_var]) obj[vars.color_var] = leaves[0][vars.color_var]
            leaves.push(obj)
          }
        })
        
        return leaves.sort(function(a,b){
          return a[vars.xaxis_var]-b[vars.xaxis_var];
        });
        
      })
      .entries(vars.data)
    
    nested.forEach(function(d, i){
      d.total = d3.sum(d.values, function(dd){ return dd[vars.yaxis_var]; })
      d[vars.text_var] = d.values[0][vars.text_var]
      d[vars.id_var] = d.values[0][vars.id_var]
    })
    // return nested
    
    return nested.sort(function(a,b){
          
      var s = vars.sort == "value" ? "total" : vars.sort
      
      a_value = find_variable(a,s)
      b_value = find_variable(b,s)
      
      if (s == vars.color_var) {
      
        a_value = d3.rgb(a_value).hsl()
        b_value = d3.rgb(b_value).hsl()
        
        if (a_value.s == 0) a_value = 361
        else a_value = a_value.h
        if (b_value.s == 0) b_value = 361
        else b_value = b_value.h
        
      }
      
      if(a_value<b_value) return vars.order == "desc" ? -1 : 1;
      if(a_value>b_value) return vars.order == "desc" ? 1 : -1;
      return 0;
      
    });
    
  }

  //===================================================================
    
};
