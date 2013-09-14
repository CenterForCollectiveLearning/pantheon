function generate_treemap() {

    var width = 725,
        height = 560,
        margin = {
            top: 0,
            right: 0,
            bottom: 0,
            left: 0
    };

    //color = d3.scale.category20();
    var treemap = d3.layout.treemap().padding(0).size([width, height]).value(function (d) {
        return (d.value !== undefined) ? d.value : d.numppl;
    });

    $("#viz svg").empty();
    var svg = d3.select("#viz svg")
        .attr("width", width)
        .attr("height", height)
        .append("g")
        .attr("transform", "translate(-.5,-.5)");

    var query = gimmeQuery();
    var gimme_the_domain = (selected_domain.charAt(0) == "-") ? "&occ=" + urlify(selected_domain.substring(1)) : "&dom=" + urlify(selected_domain);
    var url = "http://culture.media.mit.edu:8080/?query=" + query + gimme_the_domain + "&country=" + selected_country + "&lang=" + selected_region + "&b=" + from + "&e=" + to + "&L=" + l;
    console.log("Treemap API call", url);
    d3.json(url, function (json_data) {

        countries_filtered = {
            "name": "-",
            "children": Array()
        };
        countries_filtered.children = json_data.data;

        //console.log(countries_filtered);

        var cell = svg.data([countries_filtered]).selectAll("g").data(treemap.nodes).enter().append("g").attr("class", function (d) {
            if (!d.children || d.children.length === 0) {
                return "cell_" + spacesBeGone(d.parent.name.toLowerCase()) + " leaf cell";
            } else {
                return "parent cell";
            }
        }).attr("transform", function (d) {
            return "translate(" + d.x + "," + d.y + ")";
        });

        cell.append("rect").attr("width", function (d) {
            return d.dx;
        }).attr("height", function (d) {
            return d.dy;
        }).style("cursor", "pointer").style("fill", function (d) {
            if (d.parent && d.parent.parent && d.parent.parent.name != "-") {
                if(gimmeQuery() == "language")
                    return color_domain_languages(d.parent.parent.name);
                else if(gimmeQuery() == "country")
                    return color_domain_countries(d.parent.parent.name);
                else
                    return color_domain(d.parent.parent.name);
            }
            else if (d.parent && d.parent.parent && d.parent.parent.name == "-") {
                if(gimmeQuery() == "language")
                    return color_domain_languages(d.parent.name);
                if(gimmeQuery() == "country")
                    return color_domain_countries(d.parent.name);
                else
                    return color_domain(d.parent.name);
            }
            else {
                return null;
            }

        });

        d3.selectAll(".leaf").on("mousemove", function (d) {
          //todo, while language tooltips is not implemented
          //change later
          if(individuals_by_sumfin[d.name] != undefined) {
            var suffix = (individuals_by_sumfin[d.name].length > 1) ? "individuals" : "individual";
            var html_to_show = "<span style='font-weight:700;font-size:110%;letter-spacing:2px'>" + d.name + "</span><br />" + individuals_by_sumfin[d.name].length + " " + suffix + "<div style='width:100%;border-top:1px solid #cccccc;height:5px;margin-top:6px;'></div>";

            var tooltip_individual_threshold = (individuals_by_sumfin[d.name].length < 5) ? individuals_by_sumfin[d.name].length : 5;
            for (var i = 0; i < tooltip_individual_threshold; i++) {
                html_to_show += individuals_by_sumfin[d.name][i].fb_name + "<span style='font-size:70%'>, " + individuals_by_sumfin[d.name][i].location + "</span><br />";
            }

            if (individuals_by_sumfin[d.name].length > tooltip_individual_threshold) {
                html_to_show += "<br /><span style='font-size:80%'>(" + (individuals_by_sumfin[d.name].length - tooltip_individual_threshold) + " more)</span>";
            }

            $("#tooltip").show().html(html_to_show).css("left", (d3.event.pageX + 150) + "px").css("top", (d3.event.pageY - 65) + "px").css("padding", "15px");
          }
          else {
            var suffix = (d.value > 1) ? "individuals" : "individual";
            var html_to_show = "<span style='font-weight:700;font-size:110%;letter-spacing:2px'>" + d.name + "</span><br />" + d.value + " " + suffix;

            $("#tooltip").show().html(html_to_show).css("left", (d3.event.pageX + 150) + "px").css("top", (d3.event.pageY - 65) + "px").css("padding", "15px");
          }
        });

        cell.append("text").attr("text-anchor", "start").attr('x', '0.2em').attr('y', '0.1em').attr('dy', '1em').attr("font-size", function (d) {
            var size = (d.dx) / 7
            if (d.dx < d.dy) var size = d.dx / 7
            else var size = d.dy / 7
            //if (size < 10) size = 10;
            //console.log(size);
            return size;
        }).style("cursor", "pointer").text(function (d) {
            return d.children ? null : d.name;
        }).each(wordWrap);

        $("#loading").hide();
        $("#viz svg").css("border", "2px solid white");
        $("#ranked_list").css("opacity", "1");
    });
}
