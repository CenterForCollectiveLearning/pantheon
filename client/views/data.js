function calcSize(n) {
    if (n.values[0].hasOwnProperty("count")){
        n.size = parseInt(n.values[0].count);
        n.name = n.key;
        delete n.key;
        delete n.values;
        return n.size;
    }
    sum = 0;
    n.children = n.values;
    n.name = n.key;
    delete n.key;
    delete n.values;
    for (var i in n.children){
        sum = sum + calcSize(n.children[i]);
    }
    n.size = sum;
    return n.size;
}

var u = "https://docs.google.com/spreadsheet/pub?key=0AgfOXjbH2KOddHR3c0JDbGpLa3E1UkVpUjRhaE5JeEE&single=true&gid=2&range=A1%3AD88&output=csv";
function renderTree(url){
    d3.select("#tree").remove();
    var allData = {};
    json = ""
    $.get(url,{}, function (d) {
        data = $.csv.toObjects(d);
        k = Object.keys(data[0]);
        var command = "d3.nest()";
        var subkeys = k.slice(0,k.length-1);
        for (var i in subkeys){
            command += ".key(function(d){return d." + subkeys[i] + "})";
        }
        command += ".entries(data);";
        var nestedData = eval(command);
        allData = {key: 'occupations', values: nestedData};
        calcSize(allData);

        var m = [20, 120, 20, 120],
            w = $('.page-middle').width(),
            h = 400 - m[0] - m[2],
            i = 0,
            root;

        var tree = d3.layout.tree()
            .size([h, w]);

        var diagonal = d3.svg.diagonal()
            .projection(function(d) { return [d.y, d.x]; });

        var vis = d3.select("#classtree").append("svg:svg").attr("id", "tree")
            .attr("width", w + m[1] + m[3])
            .attr("height", h + m[0] + m[2])
            .append("svg:g")
            .attr("transform", "translate(" + m[3] + "," + m[0] + ")");

        root = allData;
        root.x0 = h / 2;
        root.y0 = 0;

        function toggleAll(d) {
            if (d.children) {
                d.children.forEach(toggleAll);
                toggle(d);
            }
        }

        // Initialize the display to show a few nodes.
        root.children.forEach(toggleAll);
        //toggle(root.children[1]);
        update(root);

        function update(source) {
            var duration = d3.event && d3.event.altKey ? 5000 : 500;

            // Compute the new tree layout.
            var nodes = tree.nodes(root).reverse();

            // Normalize for fixed-depth.
            nodes.forEach(function(d) { d.y = d.depth * 180; });

            // Update the nodes…
            var node = vis.selectAll("g.node")
                .data(nodes, function(d) { return d.id || (d.id = ++i); });

            // Enter any new nodes at the parent's previous position.
            var nodeEnter = node.enter().append("svg:g")
                .attr("class", "node")
                .attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; })
                .on("click", function(d) { toggle(d); update(d); });

            nodeEnter.append("svg:circle")
                .attr("r", 1e-6)
                .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; });

            nodeEnter.append("svg:text")
                .attr("x", function(d) { return d.children || d._children ? -10 : 10; })
                .attr("dy", ".35em")
                .attr("text-anchor", function(d) { return d.children || d._children ? "end" : "start"; })
                .style("fill", "#FFFFFF")
                .text(function(d) { return d.name + " (" + d.size.toString() + ")";
                })
                .style("fill-opacity", 1e-6);

            // Transition nodes to their new position.
            var nodeUpdate = node.transition()
                .duration(duration)
                .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

            nodeUpdate.select("circle")
                .attr("r", 4.5)
                //.attr("r", function(d){ return d.size ? Math.sqrt(d.size/1000) : 4.5; } )
                .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; });

            nodeUpdate.select("text")
                .style("fill-opacity", 1);

            // Transition exiting nodes to the parent's new position.
            var nodeExit = node.exit().transition()
                .duration(duration)
                .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
                .remove();

            nodeExit.select("circle")
                .attr("r", 1e-6);

            nodeExit.select("text")
                .style("fill-opacity", 1e-6);

            // Update the links…
            var link = vis.selectAll("path.link")
                .data(tree.links(nodes), function(d) { return d.target.id; });

            // Enter any new links at the parent's previous position.
            link.enter().insert("svg:path", "g")
                .attr("class", "link")
                .attr("d", function(d) {
                    var o = {x: source.x0, y: source.y0};
                    return diagonal({source: o, target: o});
                })
                .transition()
                .duration(duration)
                .attr("d", diagonal);

            // Transition links to their new position.
            link.transition()
                .duration(duration)
                .attr("d", diagonal);

            // Transition exiting nodes to the parent's new position.
            link.exit().transition()
                .duration(duration)
                .attr("d", function(d) {
                    var o = {x: source.x, y: source.y};
                    return diagonal({source: o, target: o});
                })
                .remove();

            // Stash the old positions for transition.
            nodes.forEach(function(d) {
                d.x0 = d.x;
                d.y0 = d.y;
            });
        }

        // Toggle children.
        function toggle(d) {
            if (d.children) {
                d._children = d.children;
                d.children = null;
            } else {
                d.children = d._children;
                d._children = null;
            }
        }
        //d3.select(self.frameElement).style("height", h + "px");
    });
}

Template.data.rendered = function() {
    renderTree(u);
}
