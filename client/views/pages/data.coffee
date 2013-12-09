calcSize = (n) ->
  if n.values[0].hasOwnProperty("count")
    n.size = parseInt(n.values[0].count)
    n.name = n.key
    delete n.key

    delete n.values

    return n.size
  sum = 0
  n.children = n.values
  n.name = n.key
  delete n.key

  delete n.values

  for i of n.children
    sum = sum + calcSize(n.children[i])
  n.size = sum
  n.size
renderTree = (url) ->
  d3.select("#tree").remove()
  allData = {}
  json = ""
  $.get url, {}, (d) ->
    toggleAll = (d) ->
      if d.children
        d.children.forEach toggleAll
        toggle d
    
    # Initialize the display to show a few nodes.
    
    #toggle(root.children[1]);
    update = (source) ->
      duration = (if d3.event and d3.event.altKey then 5000 else 500)
      
      # Compute the new tree layout.
      nodes = tree.nodes(root).reverse()
      
      # Normalize for fixed-depth.
      nodes.forEach (d) ->
        d.y = d.depth * 180

      
      # Update the nodes…
      node = vis.selectAll("g.node").data(nodes, (d) ->
        d.id or (d.id = ++i)
      )
      
      # Enter any new nodes at the parent's previous position.
      nodeEnter = node.enter().append("svg:g").attr("class", "node").attr("transform", (d) ->
        "translate(" + source.y0 + "," + source.x0 + ")"
      ).on("click", (d) ->
        toggle d
        update d
      )
      nodeEnter.append("svg:circle").attr("r", 1e-6).style "fill", (d) ->
        (if d._children then "lightsteelblue" else "#fff")

      nodeEnter.append("svg:text").attr("x", (d) ->
        (if d.children or d._children then -10 else 10)
      ).attr("dy", ".35em").attr("text-anchor", (d) ->
        (if d.children or d._children then "end" else "start")
      ).style("fill", "#FFFFFF").text((d) ->
        d.name + " (" + d.size.toString() + ")"
      ).style "fill-opacity", 1e-6
      
      # Transition nodes to their new position.
      nodeUpdate = node.transition().duration(duration).attr("transform", (d) ->
        "translate(" + d.y + "," + d.x + ")"
      )
      
      #.attr("r", function(d){ return d.size ? Math.sqrt(d.size/1000) : 4.5; } )
      nodeUpdate.select("circle").attr("r", 4.5).style "fill", (d) ->
        (if d._children then "lightsteelblue" else "#fff")

      nodeUpdate.select("text").style "fill-opacity", 1
      
      # Transition exiting nodes to the parent's new position.
      nodeExit = node.exit().transition().duration(duration).attr("transform", (d) ->
        "translate(" + source.y + "," + source.x + ")"
      ).remove()
      nodeExit.select("circle").attr "r", 1e-6
      nodeExit.select("text").style "fill-opacity", 1e-6
      
      # Update the links…
      link = vis.selectAll("path.link").data(tree.links(nodes), (d) ->
        d.target.id
      )
      
      # Enter any new links at the parent's previous position.
      link.enter().insert("svg:path", "g").attr("class", "link").attr("d", (d) ->
        o =
          x: source.x0
          y: source.y0

        diagonal
          source: o
          target: o

      ).transition().duration(duration).attr "d", diagonal
      
      # Transition links to their new position.
      link.transition().duration(duration).attr "d", diagonal
      
      # Transition exiting nodes to the parent's new position.
      link.exit().transition().duration(duration).attr("d", (d) ->
        o =
          x: source.x
          y: source.y

        diagonal
          source: o
          target: o

      ).remove()
      
      # Stash the old positions for transition.
      nodes.forEach (d) ->
        d.x0 = d.x
        d.y0 = d.y

    
    # Toggle children.
    toggle = (d) ->
      if d.children
        d._children = d.children
        d.children = null
      else
        d.children = d._children
        d._children = null
    data = $.csv.toObjects(d)
    k = Object.keys(data[0])
    command = "d3.nest()"
    subkeys = k.slice(0, k.length - 1)
    for i of subkeys
      command += ".key(function(d){return d." + subkeys[i] + "})"
    command += ".entries(data);"
    nestedData = eval_(command)
    allData =
      key: "occupations"
      values: nestedData

    calcSize allData
    m = [20, 120, 20, 120]
    w = 800 - m[1] - m[3]
    h = 400 - m[0] - m[2]
    i = 0
    root = undefined
    tree = d3.layout.tree().size([h, w])
    diagonal = d3.svg.diagonal().projection((d) ->
      [d.y, d.x]
    )
    vis = d3.select("#classtree").append("svg:svg").attr("id", "tree").attr("width", w + m[1] + m[3]).attr("height", h + m[0] + m[2]).append("svg:g").attr("transform", "translate(" + m[3] + "," + m[0] + ")")
    root = allData
    root.x0 = h / 2
    root.y0 = 0
    root.children.forEach toggleAll
    update root

u = "https://docs.google.com/spreadsheet/pub?key=0AgfOXjbH2KOddHR3c0JDbGpLa3E1UkVpUjRhaE5JeEE&single=true&gid=2&range=A1%3AD89&output=csv"

Template.data.events =
  "click a": (d) ->
    srcE = (if d.srcElement then d.srcElement else d.target)
    point = $(srcE).attr("href")
    window.scrollTo(0, $(point).position().top-120)
    #TODO: update the address route here, then make the route work to point to a specific position on the data page!
#    window.history.pushState(null, null, '/data/'+point)

#d3.select(self.frameElement).style("height", h + "px");
Template.data.rendered = ->
  renderTree u