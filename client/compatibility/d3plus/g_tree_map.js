d3plus.tree_map = function(vars) {
  
  var covered = false
  
  // Ok, to get started, lets run our heirarchically nested
  // data object through the d3 treemap function to get a
  // flat array of data with X, Y, width and height vars
  if (vars.data) {
    var tmap_data = d3.layout.treemap()
      .round(false)
      .size([vars.width, vars.height])
      .children(function(d) { return d.children; })
      .sort(function(a, b) { return a.value - b.value; })
      .value(function(d) { return d[vars.value_var]; })
      .nodes(vars.data)
      .filter(function(d) {
        return !d.children;
      })
  }
  else {
    var tmap_data = []
  }
  
  var cell = d3.select("g.parent").selectAll("g")
    .data(tmap_data, function(d){ return d[vars.id_var]; })
  
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  // New cells enter, initialize them here
  //-------------------------------------------------------------------
  
  // cell aka container
  var cell_enter = cell.enter().append("g")
    .attr("id",function(d){
      return "cell_"+d[vars.id_var].replace(" ", "_")
    })
    .attr("opacity", 0)
    .attr("transform", function(d) {
      return "translate(" + d.x + "," + d.y + ")"; 
    })
    
  // rectangle
  cell_enter.append("rect")
    .attr("stroke",vars.background)
    .attr("stroke-width",1)
    .attr("opacity",0.85)
    .attr('width', function(d) {
      return d.dx+'px'
    })
    .attr('height', function(d) { 
      return d.dy+'px'
    })
    .attr("fill", function(d){
      return find_color(d);
    })
    .attr("shape-rendering","crispEdges")
    
  // text (name)
  cell_enter.append("text")
    .attr("opacity", 1)
    .attr("text-anchor","start")
    .style("font-weight",vars.font_weight)
    .attr("font-family",vars.font)
    .attr('class','name')
    .attr('x','0.2em')
    .attr('y','0em')
    .attr('dy','0em')
    .attr("fill", function(d){ 
      var color = find_color(d)
      return d3plus.utils.text_color(color); 
    })
    .style("pointer-events","none")
    
  // text (share)
  cell_enter.append("text")
    .attr('class','share')
    .attr("text-anchor","middle")
    .style("font-weight",vars.font_weight)
    .attr("font-family",vars.font)
    .attr("fill", function(d){
      var color = find_color(d)
      return d3plus.utils.text_color(color); 
    })
    .attr("fill-opacity",0.5)
    .style("pointer-events","none")
    .text(function(d) {
      var root = d;
      while(root.parent){ root = root.parent; } // find top most parent node
      d.share = vars.number_format((d.value/root.value)*100,"share")+"%";
      return d.share;
    })
    .attr('font-size',function(d){
      var size = (d.dx)/7
      if(d.dx < d.dy) var size = d.dx/7
      else var size = d.dy/7
      if (size < 10) size = 10;
      return size
    })
    .attr('x', function(d){
      return d.dx/2
    })
    .attr('y',function(d){
      return d.dy-(parseInt(d3.select(this).attr('font-size'),10)*0.25)
    })
    .each(function(d){
      var el = d3.select(this).node().getBBox()
      if (d.dx < el.width) d3.select(this).remove()
      else if (d.dy < el.height) d3.select(this).remove()
    })
    
    
  
  //===================================================================
  
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  // Update, for cells that are already in existance
  //-------------------------------------------------------------------
  
  small_tooltip = function(d) {
    console.log("in small_tooltip")

    d3plus.tooltip.remove(vars.type)
    var ex = {}
    ex[vars.text_format("share")] = d.share
    var tooltip_data = get_tooltip_data(d,"short",ex)
    var id = find_variable(d,vars.id_var)
    
    d3plus.tooltip.create({
      "title": find_variable(d,vars.text_var),
      "color": find_color(d),
      "icon": find_variable(d,"icon"),
      "style": vars.icon_style,
      "id": vars.type,
      "x": d3.event.clientX,
      "y": d3.event.clientY,
      "offset": 3,
      "arrow": true,
      "mouseevents": d3.select("#cell_"+id).node(),
      "footer": footer_text(),
      "data": tooltip_data
    })
  }
  
  cell
    .on(d3plus.evt.over,function(d){
      var id = find_variable(d,vars.id_var).replace(" ", "_"),
          self = d3.select("#cell_"+id).node()

      self.parentNode.appendChild(self)

      d3.select("#cell_"+id).select("rect")
        .style("cursor","pointer")
        .attr("opacity",1)

      // Get parameters from DOM
      // Subscription Parameters

      var vizMode = Session.get("vizMode");
      if (vizMode === "country_exports") {
        var countryCode = Session.get("country");
        var countryName = countryCode === "all" ? "All" : Countries.findOne({countryCode: countryCode}).countryName;
        var category = id.replace("_", " ");
        var categoryLevel = "occupation";
      } else if (vizMode === "domain_exports_to") {
        var countryCode = id.replace("_", " ");
        var countryName = countryCode === "all" ? "All" : Countries.findOne({countryCode: countryCode}).countryName;
        var category = Session.get("category");
        var categoryLevel = Session.get("categoryLevel");
      }

      console.log(category, categoryLevel);
      
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
    })
    .on(d3plus.evt.out,function(d){
      Template.tooltip.top5 = null;
      Session.set("showTooltip", false);
      $("#tooltip").empty();
      
      var id = find_variable(d,vars.id_var).replace(" ", "_");
      
      d3.select("#cell_"+id).select("rect")
        .attr("opacity",0.85)
        
      if (!covered) {
        d3plus.tooltip.remove(vars.type)
      }
      
    })
    .on(d3plus.evt.down,function(d){
      
      covered = true
        
      var id = find_variable(d,vars.id_var),
          self = d3.select("#cell_"+id).node()
      
      make_tooltip = function(html) {
      
        d3.select("#cell_"+id).select("rect")
          .attr("opacity",0.85)
        
        d3plus.tooltip.remove(vars.type)

        var ex = {}
        ex[vars.text_format("share")] = d.share
        var tooltip_data = get_tooltip_data(d,"long",ex)
        
        d3plus.tooltip.create({
          "title": find_variable(d,vars.text_var),
          "color": find_color(d),
          "icon": find_variable(d,"icon"),
          "style": vars.icon_style,
          "id": vars.type,
          "fullscreen": true,
          "html": html,
          "footer": vars.data_source,
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
    .on(d3plus.evt.move,function(d){
      covered = false
      d3plus.tooltip.move(d3.event.clientX,d3.event.clientY,vars.type)
    })
  
  cell.transition().duration(d3plus.timing)
    .attr("transform", function(d) { 
      return "translate(" + d.x + "," + d.y + ")"; 
    })
    .attr("opacity", 1)
    
  // update rectangles
  cell.select("rect").transition().duration(d3plus.timing)
    .attr('width', function(d) {
      return d.dx+'px'
    })
    .attr('height', function(d) { 
      return d.dy+'px'
    })
    .attr("fill", function(d){
      return find_color(d);
    })

  // text (name)
  cell.select("text.name").transition()
    .duration(d3plus.timing/2)
    .attr("opacity", 0)
    .attr("fill", function(d){ 
      var color = find_color(d)
      return d3plus.utils.text_color(color); 
    })
    .transition().duration(d3plus.timing/2)
    .each("end", function(d){
      d3.select(this).selectAll("tspan").remove();
      var name = find_variable(d,vars.text_var)
      if(name && d.dx > 30 && d.dy > 30){
        var text = []
        var arr = vars.name_array ? vars.name_array : [vars.text_var,vars.id_var]
        arr.forEach(function(n){
          var name = find_variable(d,n)
          if (name) text.push(name)
        })
        
        var size = (d.dx)/7
        if(d.dx < d.dy) var size = d.dx/7
        else var size = d.dy/7
        if (size < 10) size = 10;
        
        d3plus.utils.wordwrap({
          "text": text,
          "parent": this,
          "width": d.dx,
          "height": d.dy-size,
          "resize": true
        })
      }
      
      d3.select(this).transition().duration(d3plus.timing/2)
        .attr("opacity", 1)
    })


  // text (share)
  cell.select("text.share").transition().duration(d3plus.timing/2)
    .attr("opacity", 0)
    .attr("fill", function(d){ 
      var color = find_color(d)
      return d3plus.utils.text_color(color); 
    })
    .each("end",function(d){
      d3.select(this)
        .text(function(d){
          var root = d.parent;
          while(root.parent){ root = root.parent; } // find top most parent node
          d.share = vars.number_format((d.value/root.value)*100,"share")+"%";
          return d.share;
        })
        .attr('font-size',function(d){
          var size = (d.dx)/7
          if(d.dx < d.dy) var size = d.dx/7
          else var size = d.dy/7
          if (size < 10) size = 10;
          return size
        })
        .attr('x', function(d){
          return d.dx/2
        })
        .attr('y',function(d){
          return d.dy-(parseInt(d3.select(this).attr('font-size'),10)*0.25)
        })
        .each(function(d){
          var el = d3.select(this).node().getBBox()
          if (d.dx < el.width) d3.select(this).remove()
          else if (d.dy < el.height) d3.select(this).remove()
        })
      d3.select(this).transition().duration(d3plus.timing/2)
        .attr("opacity", 1)
    })
    

  //===================================================================
  
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  // Exis, get rid of old cells
  //-------------------------------------------------------------------
  
  cell.exit().transition().duration(d3plus.timing)
    .attr("opacity", 0)
    .remove()

  //===================================================================
  
}
