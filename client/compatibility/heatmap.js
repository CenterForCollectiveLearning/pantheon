// Helper functions

// Aggregate without summing bottom level
var aggregate = function (obj, values, context) {
    if (!values.length)
        return obj;
    var byFirst = _.groupBy(obj, values[0], context),
    rest = values.slice(1);
    for (var prop in byFirst) {
        byFirst[prop] = aggregate(byFirst[prop], rest, context);
    }
    return byFirst;
};

// Aggregate to bottom level, then sum
var aggregate_counts = function (obj, values, context) {
    if (!values.length)
        return obj.length;
    var byFirst = _.groupBy(obj, values[0], context),
    rest = values.slice(1);
    for (var prop in byFirst) {
        byFirst[prop] = aggregate_counts(byFirst[prop], rest, context);
    }
    return byFirst;
};

String.prototype.capitalize = function() {
    // Match letters at beginning of string or after white space character
    return this.toLowerCase().replace(/(?:^|\s)\S/g, function(a) { return a.toUpperCase(); });
};

function generate_heatmap(gender) {
    var width = 940,
        height = 2000,
        header_height = 155,
        margin = {
            top: 10,
            right: 10,
            bottom: 5,
            left: 30
    };

    var fill = d3.scale.linear()
        .domain([0, 1])
        .range(["#f1e7d0", "red"]);

    var url = "http://culture.media.mit.edu:8080/?query=people&dom=all&country=all&lang=en&b=" + from + "&e=" + to + "&L=" + l;

    $("#viz svg").empty();

    var svg = d3.select("#viz svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .style("background-color", "#202020")
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + 0 + ")");

    // Append SVG to hold column titles
    d3.select("#viz_pane > svg").remove();
    header_svg = d3.select("#viz_pane").insert("svg", ":first-child")
            .attr("width", width + margin.left + margin.right)
            .attr("height", header_height)
            .style("background-color", "#202020")
        .append("g")
            .attr("transform", "translate(" + margin.left + "," + header_height + ")");

    var x = d3.scale.ordinal().rangeBands([0, height]);
    var y = d3.scale.ordinal().rangeBands([0, width]);
    var z = d3.scale.linear().domain([0, 4]).clamp(true);
    var c = d3.scale.category10().domain(d3.range(10));

    d3.json(url, function(j) {
        var matrix = [];  // matrix mapping countries to industries
        var inv_matrix = [];  // matrix mapping industries to countries
        var industries = []; // entities on x-axis (list of industries)
        var countries = [];  // entities on y-axis (list of countries)
        var links = [];  // list of {industry, country, value}
        var min_values = {};  // keyed by country
        var max_values = {};  // keyed by country
        var fills = {};  // keyed by country
        var country_counts = {};
        var industry_counts = {};
        var input = aggregate_counts(j.data, ['countryCode', 'industry', 'gender']);

        var grouped_individuals = aggregate(j.data, ['countryCode', 'industry']);
        console.log(grouped_individuals);

        for (var countryCode in input) {
            for (var industry in input[countryCode]) {
                var f_res = (!isNaN(input[countryCode][industry]['Female'])) ? input[countryCode][industry]['Female'] : 0;
                var m_res = (!isNaN(input[countryCode][industry]['Male'])) ? input[countryCode][industry]['Male'] : 0;
                var results = {
                    'both': f_res + m_res,
                    'male': m_res,
                    'female': f_res,
                    'ratio': ((f_res / m_res) == Number.POSITIVE_INFINITY) ? 100 : f_res / m_res
                };

                    var value = results[gender];

                    links.push({
                        "country": countryCode,
                        "industry": industry,
                        "value": value
                    });

                    if (industries.indexOf(industry) == -1)
                        industries.push(industry);

                    if (countries.indexOf(countryCode) == -1) {
                        countries.push(countryCode);
                        min_values[countryCode] = Number.MAX_VALUE;
                        max_values[countryCode] = Number.MIN_VALUE;
                    }

                    if (value < min_values[countryCode])
                        min_values[countryCode] = value;
                    if (value > max_values[countryCode])
                        max_values[countryCode] = value;

                }
            }

            var country_count = countries.length,
            industry_count = industries.length;

    // Populate matrix
    countries.forEach(function(country, i) {
        country_counts[i] = 0;
        matrix[i] = d3.range(industry_count).map(function(j) {return {x: j, y: i, z: 0}; });
    });

    // Populate inverted matrix
    industries.forEach(function(industry, i) {
        industry_counts[i] = 0;
        inv_matrix[i] = d3.range(country_count).map(function(j) {return {x: i, y: j, z: 0}; });
    });

    // Convert links to matrix.
    links.forEach(function(link) {
        var country = link["country"];
        var industry = link["industry"];
        var country_index = countries.indexOf(country);
        var industry_index = industries.indexOf(industry);
        var value = link["value"] / max_values[country];

        if (max_values[country] === Number.MIN_VALUE) {
            // console.log(country);
        }

        country_counts[country_index] += 1;
        industry_counts[industry_index] += 1;

        matrix[country_index][industry_index].z += value;
        inv_matrix[industry_index][country_index].z += value;
    });

    // Precompute ordering
    var country_orders = {
        name: d3.range(country_count).sort(function(a, b) { return d3.ascending(countries[a], countries[b]); }),
        count: d3.range(country_count).sort(function(a, b) { return d3.ascending(country_counts[b], country_counts[a]); })
    };

    var industry_orders = {
        name: d3.range(industry_count).sort(function(a, b) { return d3.ascending(industries[a], industries[b]); }),
        count: d3.range(industry_count).sort(function(a, b) { return d3.descending(industry_counts[a], industry_counts[b]); })
    };

    // Default sort orders
    x.domain(country_orders[$("#row").val()]);
    y.domain(industry_orders[$("#row").val()]);

    svg.append("rect")
        .attr("class", "rect-background")
        .attr("width", width)
        .attr("height", height);

    // Rows
    var row = svg.selectAll(".row")
        .data(matrix)
        .enter()
      .append("g")
        .attr("class", "row")
        .attr("transform", function(d, i) { return "translate(0," + x(i) + ")"; });

    row.append("line")
        .attr("x2", width);

    row.append("text")
        .attr("class", "row-title")
        .attr("x", -6)
        .attr("y", x.rangeBand() / 2)
        .attr("dy", ".32em")
        .attr("text-anchor", "end")
        .attr("font-size", "9pt")
        .text(function(d, i) { return countries[i]; });

    // Columns
    var column = svg.selectAll(".column")
        .data(inv_matrix)
        .enter().append("g")
        .attr("class", "column")
        .attr("transform", function(d, i) { return "translate(" + y(i) + ")rotate(-90)"; })
        .each(column);

    column.append("line")
        .attr("x1", -width);

    header_svg.selectAll(".column-title")
        .data(inv_matrix)
        .enter()
        .append("text")
        .attr("class", "column-title")
        .attr("transform", function(d, i) { return "translate(" + y(i) + ")rotate(-90)"; })
        .attr("x", 6)
        .attr("y", y.rangeBand()/ 2)
        .attr("dy", ".32em")
        .attr("text-anchor", "start")
        .text(function(d, i) { return industries[i].capitalize(); });

    // column.append("text")
    //     .attr("x", 6)
    //     .attr("y", y.rangeBand()/ 2)
    //     .attr("dy", ".32em")
    //     .attr("text-anchor", "start")
    //     .text(function(d, i) {
    //     return industries[i].capitalize();
    // Cells

    function column(column) {
        var cell = d3.select(this).selectAll(".cell")
        .data(column.filter(function(d) { return d.z; }))
        .enter().append("rect")
        .attr("class", "cell")
        .attr("x", function(d) { return -x(d.y) - x.rangeBand(); })
        .attr("width", (Math.round(x.rangeBand()*10)/10) - 0.1)
        .attr("height", (Math.round(y.rangeBand()*10)/10) - 0.5)
        // .style("opacity", function(d) { return 0.1 + 0.9 * (d.z); })
        .style("fill", function(d) { return fill(d.z); })
        .on("mousemove", mouseover)
        .on("mouseout", mouseout);
    }

    /* Note that p returns an object with x, y (relevant indices), and z as attributes */
    function mouseover(p) {
        var country_code = countries[p.y];
        var industry = industries[p.x];
        var individuals = grouped_individuals[country_code][industry];

        d3.selectAll(".row text").classed("active", function(d, i) { return i == p.y; });
        d3.selectAll(".column-title").classed("active", function(d, i) { return i == p.x; });

        if(individuals !== undefined) {
            var suffix = (individuals.length > 1) ? "individuals" : "individual";
            var html_to_show = "<span style='font-weight:700;font-size:110%;letter-spacing:2px'>" + country[country_code] + ": " + industry + "</span><br />" + individuals.length + " " + suffix + "<div style='width:100%;border-top:1px solid #cccccc;height:5px;margin-top:6px;'></div>";

            var tooltip_individual_threshold = (individuals.length < 5) ? individuals.length : 5;
            for (var i = 0; i < tooltip_individual_threshold; i++) {
                html_to_show += individuals[i].fb_name + "<span style='font-size:70%'>, " + individuals[i].location + "</span><br />";
            }

            if (individuals.length > tooltip_individual_threshold) {
                html_to_show += "<br /><span style='font-size:80%'>(" + (individuals.length - tooltip_individual_threshold) + " more)</span>";
            }

            // Flip tooltip to left if it overflows window
            $("#tooltip").html(html_to_show)
            if($(window).width() >= d3.event.pageX + 150 + 30 + $("#tooltip").width()) {
                $("#tooltip").show().css("left", (d3.event.pageX + 150) + "px").css("top", (d3.event.pageY - 65) + "px").css("padding", "15px");
            } else {
                $("#tooltip").show().css("left", (d3.event.pageX - 150 - $("#tooltip").width()) + "px").css("top", (d3.event.pageY - 65) + "px").css("padding", "15px");
            }
        }
        else {
            var suffix = (p.value > 1) ? "individuals" : "individual";
            var html_to_show = "<span style='font-weight:700;font-size:110%;letter-spacing:2px'>" + p.name + "</span><br />" + p.value + " " + suffix;

            $("#tooltip").html(html_to_show);
            if($(window).width() >= d3.event.pageX + 150 + 30 + $("#tooltip").width()) {
                $("#tooltip").show().css("left", (d3.event.pageX + 150) + "px").css("top", (d3.event.pageY - 65) + "px").css("padding", "15px");
            } else {
                $("#tooltip").show().css("left", (d3.event.pageX - 150 - $("#tooltip").width()) + "px").css("top", (d3.event.pageY - 65) + "px").css("padding", "15px");
            }
        }
    }

    function mouseout() {
        d3.selectAll("text").classed("active", false);
        $("#tooltip").empty().css("padding", 0);
    }

    function country_order(value) {
        x.domain(country_orders[value]);

        var t = svg.transition().duration(500);

        t.selectAll(".row")
        .delay(function(d, i) { return x(i) * 1; })
        .attr("transform", function(d, i) { return "translate(0," + x(i) + ")"; });

        t.selectAll(".column")
        .delay(function(d, i) { return x(i) * 1; })
        .attr("transform", function(d, i) { return "translate(" + y(i) + ")rotate(-90)"; })
        .selectAll(".cell")
        .delay(function(d) { return x(d.x) ; })
        .attr("x", function(d) { return -x(d.y) - x.rangeBand(); });
    }

    function industry_order(value) {
        y.domain(industry_orders[value]);

        var t = svg.transition().duration(500);

        t.selectAll(".row")
        .delay(function(d, i) { return x(i) * 1; })
        .attr("transform", function(d, i) { return "translate(0," + x(i) + ")"; });

        t.selectAll(".column")
        .delay(function(d, i) { return x(i) * 1; })
        .attr("transform", function(d, i) { return "translate(" + y(i) + ")rotate(-90)"; })
        .selectAll(".cell")
        .delay(function(d) { return x(d.x) ; })
        .attr("x", function(d) { return -x(d.y) - x.rangeBand(); });
    }

    /// Legend ///
    var gradient = d3.select(".color_scale svg").append("svg:linearGradient")
        .attr("id", "gradient")
        .attr("x1", "0%")
        .attr("y1", "0%")
        .attr("x2", "100%")
        .attr("y2", "0%")
        .attr("spreadMethod", "pad");

    gradient.append("svg:stop")
        .attr("offset", "0%")
        .attr("stop-color", "#f1e7d0")
        .attr("stop-opacity", 1);

    gradient.append("svg:stop")
        .attr("offset", "100%")
        .attr("stop-color", "red")
        .attr("stop-opacity", 1);

    d3.select(".color_scale svg").append("rect")
        .attr("width", width + margin.left + margin.right)
        .attr("height", "30px");

    d3.select(".color_scale svg").append("text")
        .attr("x", 5)
        .attr("y", "21px")
        .text("0%");

    d3.select(".color_scale svg").append("text")
        .attr("x", width - 5)
        .attr("y", "21px")
        .text("100%");


    /// Button Presses ///
    // Sort
    // $("#row").change(function() {
    //     country_order(this.value);
    // });

    // $("#column").change(function() {
    //     industry_order(this.value);
    // });

    $("#gender").change(function() {
        generate_heatmap(this.value);
    });

    $("#loading").hide();
    });
}
