Template.accordion.rendered = function() {
    accordion = $(this.find(".accordion"))

    accordion.accordion({
            active: 0,
            collapsible: true,
            heightStyle: "content",
            fillSpace: true
        });

    accordion.accordion( "resize" );
}

Template.accordion.events = {
    "click li a": function (d) {

        $("#loading").show();

        resetControls();

        var srcE = d.srcElement ? d.srcElement : d.target;
        var option = $(srcE).attr("id")
        Session.set("vizMode", option);

        $(".top_nav_control").show();
        $(".selected").attr("class", "not_selected");
        $("#" + option).parent().attr("class", "selected");
        $("label").css("opacity", 1);


        // TODO redo this in meteor
        // $.uniform.update();

        //TODO move this elsewhere later
        if(gimmeQuery() == "domain") {
            $(".legend").fadeIn();
        }
        else {
            $(".legend").fadeOut();
        }

        updateQuestion();
        getIndividuals();
        addTreemapSvg();

        return false;
    }
}

function resetControls() {
    selected_country = "all";
    selected_region = "all";
    selected_domain = "all";

    $("#countries").val("All");
    $("#languages").val("All");
    $("#domain").val("All");
    // $.uniform.update("#countries,#languages,#domain");
}

function updateQuestion() {
    var html = "";
    var s_countries = (selected_country == "all") ? "the world" : country[selected_country],
        s_domains = (selected_domain == "all") ? "all domains" : decodeURIComponent(selected_domain),
        s_regions = (selected_region == "all") ? "the world" : region[selected_region],
        does_or_do = (selected_country == "all") ? "do" : "does",
        s_or_no_s_c = (selected_country == "all") ? "'" : "'s",
        s_or_no_s_r = (selected_region == "all") ? "'" : "'s",
        speakers_or_no_speakers = (selected_region == "all") ? "" : " speakers";


    if(s_domains.charAt(0) == "-") {
        console.log(s_domains.charAt(s_domains.length-1));
        if(s_domains.charAt(s_domains.length-1) == "y")
            s_domains = s_domains.substring(1, s_domains.length-1) + "ies";
        else
            s_domains = s_domains.substring(1) + "s";
    }
    else if(s_domains.charAt(0) == "+") {
        s_domains = "in the area of " + s_domains.substring(1);
    }


    switch (selected_visualization) {
        case "exports":
            html = "What does " + s_countries + " export?";
            break;
        case "imports":
            html = (selected_region == "all") ? "What does the world import?" : "What do " + s_regions + " speakers import?";
            break;
        case "exports_to":
            html = "Who exports " + s_domains + "?";
            break;
        case "imports_from":
            html = "Who imports " + s_domains + "?";
            break;
        case "exporters_of":
            html = "What does " + s_countries + " export to " + s_regions + speakers_or_no_speakers + "?";
            break;
        case "importers_of":
            html = "Where does " + s_countries + " export " + s_domains + " to?";
            break;
    }

    $("#question").html(html);
}

function getIndividuals() {
    $("#ranked_list .content").empty();

    //what are we grouping individuals by
    var by_what = "";
    if(gimmeQuery() == "domain")
        by_what = "occupation";
    else if(gimmeQuery() == "language")
        by_what = "";
    else if(gimmeQuery() == "country")
        by_what = "countryName";

    var lang_bit = (selected_region == "all" ) ? "" : "&lang=" + selected_region;

    var gimme_the_domain;
    if(selected_domain.charAt(0) == "-")
        gimme_the_domain = "&occ=" + urlify(selected_domain.substring(1));
    else if(selected_domain.charAt(0) == "+")
        gimme_the_domain = "&ind=" + urlify(selected_domain.substring(1));
    else
        gimme_the_domain = "&dom=" + urlify(selected_domain);

    var url = "http://culture.media.mit.edu:8080/?query=people&country=" + selected_country + gimme_the_domain + lang_bit + "&b=" + from + "&e=" + to + "&L=" + l;
    console.log("getIndividuals", url);

    //for ranked list
    d3.json(url+"&limit=10", function (json_data) {
        individuals = json_data.data;
        populateRanking();
    });

    //for treemap cells
    d3.json(url, function (json_data) {
        individuals_by_sumfin = new Object();

        if(by_what != "") {
            $.each(json_data.data, function (key, val) {
                getIndividualsRecursively(key, val, by_what);
            });
        }

        //console.log(individuals_by_sumfin);

        $("#loading").fadeOut();
    });
}

function addTreemapSvg() {
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
        return (d.value != undefined) ? d.value : d.numppl;
    });

    var svg = d3.select("#viz svg").attr("width", width).attr("height", height).append("g").attr("transform", "translate(-.5,-.5)");

    var query = gimmeQuery();

    var gimme_the_domain;
    if(selected_domain.charAt(0) == "-")
        gimme_the_domain = "&occ=" + urlify(selected_domain.substring(1));
    else if(selected_domain.charAt(0) == "+")
        gimme_the_domain = "&ind=" + urlify(selected_domain.substring(1));
    else
        gimme_the_domain = "&dom=" + urlify(selected_domain);

    var url = "http://culture.media.mit.edu:8080/?query=" + query + gimme_the_domain + "&country=" + selected_country + "&lang=" + selected_region + "&b=" + from + "&e=" + to + "&L=" + l;
    console.log(url);
    d3.json(url, function (json_data) {
        //$("#viz svg").empty();

        countries_filtered = {
            "name": "-",
            "children": Array()
        };
        countries_filtered.children = json_data.data;

        //console.log(countries_filtered);

        var cell = svg.data([countries_filtered]).selectAll("g").data(treemap.nodes).enter().append("g").attr("class", function (d) {
            if (!d.children || d.children.length == 0) {
                return "cell_" + spacesBeGone(d.parent.name.toLowerCase()) + " leaf cell";
            } else {
                return "parent cell"
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

                $("#tooltip").show().html(html_to_show).css("left", (d3.event.pageX + 90) + "px").css("top", (d3.event.pageY - 95) + "px").css("padding", "15px");
            }
            else {
                var suffix = (d.value > 1) ? "individuals" : "individual";
                var html_to_show = "<span style='font-weight:700;font-size:110%;letter-spacing:2px'>" + d.name + "</span><br />" + d.value + " " + suffix;

                $("#tooltip").show().html(html_to_show).css("left", (d3.event.pageX + 90) + "px").css("top", (d3.event.pageY - 95) + "px").css("padding", "15px");
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


        //$("#loading").hide();
        $("#viz svg").css("border", "2px solid white");
        $("#ranked_list").css("opacity", "1");
    });
}
