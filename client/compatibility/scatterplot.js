var url_x = "http://culture.media.mit.edu:8080/?query=domain&lang=" + selected_region_x + "&country=" + selected_country_x + "&b=" + from + "&e=" + to + "&L=" + l;
var url_y = "http://culture.media.mit.edu:8080/?query=domain&lang=" + selected_region_y + "&country=" + selected_country_y  + "&b=" + from + "&e=" + to + "&L=" + l;

function generate_scatterplot() {
    var width = 940,
    height = 560,
    margin = {
        top: 0,
        right: 0,
        bottom: 0,
        left: 0
    };

    var x = d3.scale.linear()
    .range([0, width]);

    var y = d3.scale.linear()
    .range([height, 0]);

    var xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom");

    var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left");

    var svg = d3.select("#viz svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .style("background-color", "#202020")
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    d3.json(url_x, function(data_x) {
        d3.json(url_y, function(data_y) {

            // Create mapping from occupation to domain for coloring ater
            // Create array of {occupation, x_value, y_value}
            var data_x = data_x.data;
            var data_y = data_y.data;

            var occupations = {};
            var mapping = {};

            for (var i=0; i<data_x.length; i++) {
                var domains_x = data_x[i];
                var domains_x_name = data_x[i].name;
                var industries_x = data_x[i].children;

                for (var j=0; j<industries_x.length; j++) {
                    var occ_x = industries_x[i];
                    var occ_x_name = occ_x.name;
                    var occ_x_val = occ_x.value;
                    occupations[occ_x_name] = {"x": occ_x_val, "y": 0};

                    mapping[occ_x_name] = domains_x;
                }
            }

            for (var i=0; i<data_y.length; i++) {
                var domains_y = data_y[i];
                var domains_y_name = data_y[i].name;
                var industries_y = data_y[i].children;

                for (var j=0; j<industries_y.length; j++) {
                    var occ_y = industries_y[i];
                    var occ_y_name = occ_y.name;
                    var occ_y_val = occ_y.value;
                    
                    if (occupations.indexOf(occ_y_name) == -1) {
                        occupatons[occ_y_name] = {"x": 0, "y": occ_y_val};
                    } else {
                        occupatons[occ_y_name].y = occ_y_val;
                    }

                    if (mapping.indexOf(occ_y_name) == -1) {
                        mapping[occ_y_name] = domains_y;
                    }
                }
            }

            var occupations_array = [];
            for (var occupation in occupations) {
                occupations_array.push({
                    "occupation": occupation
                    , "x": occupations[occupation].x
                    , "y": occupations[occupation].y
                });
            }

            var x_extent = d3.extent(occupations_array, function(d) { return d.x; });
            var y_extent = d3.extent(occupations_array, function(d) { return d.y; });

            x.domain(x_extent).nice();
            y.domain(y_extent).nice();

            svg.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0," + height + ")")
                .call(xAxis)
              .append("text")
                .attr("class", "label")
                .attr("x", width)
                .attr("y", -6)
                .style("text-anchor", "end")
                .text(country_x);

            svg.append("g")
                .attr("class", "y axis")
                .call(yAxis)
              .append("text")
                .attr("class", "label")
                .attr("transform", "rotate(-90)")
                .attr("y", 6)
                .attr("dy", ".71em")
                .style("text-anchor", "end")
                .text(country_y);

            svg.append("line")
                .attr("x1", 0)
                .attr("y1", 0)
                .attr("x2", x_extent[1])
                .attr("y2", y_extent[1]);

            svg.selectAll(".dot")
                .data(occupations_array)
              .enter().append("circle")
                .attr("class", "dot")
                .attr("r", 3.5)
                .attr("cx", function(d) { return x(d.x); })
                .attr("cy", function(d) { return y(d.y); })
                .style("fill", function(d) { return color_domain(mapping[d.occupation]); });

        });
});
}ar