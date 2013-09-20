Template.treemap.dataReady = function() {
    return treemapSub.ready()
}

Template.tooltip.tooltip = function() {
    return Session.get("tooltipIndustry");
}

Template.tooltip.tooltip_data = function() {
    return Domains.findOne({ _id: Session.get("tooltipIndustry") })
}

var treeProps = {
    width: 725,
    height: 560
};

Template.treemap_svg.properties = treeProps;

var color_domains = d3.scale.ordinal()
    .domain(["INSTITUTIONS", "ARTS", "HUMANITIES", "BUSINESS & LAW", "EXPLORATION", "PUBLIC FIGURE", "SCIENCE & TECHNOLOGY", "SPORTS"])
    .range(["#ECD078", "#D95B43", "#43c1d9", "#C02942", "#546c97", "#d278c2", "#53a9f1", "#79BD9A"]);

var color_languages = d3.scale.ordinal()
    .domain(["Afro-Asiatic", "Altaic", "Austro-Asiatic", "Austronesian", "Basque", "Caucasian", "Creoles and pidgins", "Dravidian", "Eskimo-Aleut", "Indo-European", "Niger-Kordofanian", "North American Indian", "Sino-Tibetan", "South American Indian", "Tai", "Uralic"])
    .range(["#E0BA9B", "#D95B43", "#43c1d9", "#C02942", "#546c97", "#d278c2", "#53a9f1", "#79BD9A", "#A69E80", "#ECD078", "#D28574", "#E7EDEA", "#CEECEF", "#912D1D", "#DE7838", "#59AB6D"]);

var color_countries = d3.scale.ordinal()
    .domain(["Africa", "Asia", "Europe", "North America", "South America", "Oceania"])
    .range(["#E0BA9B", "#D95B43", "#43c1d9", "#C02942", "#546c97", "#d278c2"]);

Template.treemap_svg.rendered = function() {
// Don't re-render with the same parameters...?
    var context = this;
    if( this.rendered ) return;
    this.rendered = true;
    var viz = vizwhiz.viz() ;

    d3.json("/attr_isic.json", function(attr){
        d3.json("/isic_mg.json", function(data){

            var attrs = {};
            console.log(attr.data[0]);

            attr.data.forEach(function(a){
                a.isic_id = a.id
                attrs[a.id] = a
            });

            depths = [1,3,5];
            for (id in attrs) {
                obj = attrs[id];
                depths.forEach(function(d){
                    if (d <= obj.id.length) {
                        obj["nesting_"+d] = {"name":attrs[obj.id.slice(0, d)].name, "isic_id":obj.id.slice(0, d)};
                    }
                });
            }

            console.log(attrs['m7220']);
            console.log(data.data[0]);
            console.log(data.data.length);
            viz
                .type("tree_map")
                .width(725)
                .height(560)
                .id_var("isic_id")
                .attrs(attrs)
                .text_var("name")
                .value_var("num_est")
                .tooltip_info({"short": ["wage"]})
                .name_array(["name","id"])
                .total_bar({"prefix": "Total Exports: ", "suffix": " individuals"})
                .nesting(["nesting_1","nesting_3","nesting_5"])
                .depth("nesting_3")
                .font("PT Sans")
                .font_weight("lighter")
                .color_var("color");

            d3.select(context.find("svg"))
                .datum(data.data)
                .call(viz);
        })
    });

    var nested = d3.nest()
        .key(function(d) { return d.domain })
        .key(function(d) { return d.industry })
        .entries(Domains.find().fetch())
     /*
    var treemap = d3.layout.treemap()
        .padding(0)
        .size([treeProps.width, treeProps.height])
        .value(function (d) {
            return d.count;
        })
        .children(function(d) {
            return d.values;
        });

    var svg = d3.select(this.find("svg"))
        .append("g")
        .attr("transform", "translate(-.5,-.5)");
      */
    domaindata = {
        "key": "-",
        "values": nested
    };
        /*
    var cell = svg.datum(data)
        .selectAll("g")
        .data(treemap.nodes)
        .enter()
        .append("g")
        .attr("class", function (d) {
            return (!d.values || d.values.length === 0) ? "leaf cell" : "parent cell";
        })
        .attr("transform", function (d) {
            return "translate(" + d.x + "," + d.y + ")";
        });

    cell.append("rect")
        .attr("width", function (d) {
            return d.dx;
        })
        .attr("height", function (d) {
            return d.dy;
        })
        .style("cursor", "pointer")
        .style("fill", function (d) {
            if (d.depth === 3) {
                return color_domain(d.parent.parent.key);
            }
            else if (d.depth === 2) {
                return color_domain(d.parent.key);
            }
            else {
                return null;
            }
        });

    // Add text to cells
    cell.append("text")
        .attr("text-anchor", "start")
        .attr('x', '0.2em')
        .attr('y', '0.1em')
        .attr('dy', '1em')
        .attr("font-size", function (d) {
            var size = (d.dx) / 7
            if (d.dx < d.dy) var size = d.dx / 7
            else var size = d.dy / 7
            return size;
        })
        .style("cursor", "pointer")
        .text(function (d) {
            return d.values ? null : d.industry; // TODO don't hardcode this!
        })
        .each(wordWrap);

    d3.selectAll(".leaf rect").on("mouseover", function (d) {
        // TODO generalize this for other treemaps later

        Session.set("tooltipIndustry", d._id);

        $("#tooltip").css("left", (d3.event.pageX + 90) + "px").css("top", (d3.event.pageY - 95) + "px");
    });
    */
}

function wordWrap(d) {
    if (this.firstChild == null) return;

    var words = d.industry.split(' ');
    var line = new Array();
    var length = 0;
    var text = "";
    var width = d.dx;
    var height = d.dy;
    var word;

    while (words.length) {
        word = words.shift();
        line.push(word);
        if (words.length) this.firstChild.data = line.join(' ') + " " + words[0];
        else this.firstChild.data = line.join(' ');
        length = this.getBBox().width;
        if (length < width && words.length) {;
        } else {
//            console.log(word);
            text = line.join(' ');
            this.firstChild.data = text;
            if (this.getBBox().width > width) {
                text = d3.select(this).select(function () {
                    return this.lastChild;
                }).text();
                text = text + "...";
                d3.select(this).select(function () {
                    return this.lastChild;
                }).text(text);
                d3.select(this).classed("wordwrapped", true);
                break;
            }

            if (text != '') {
                d3.select(this).append("svg:tspan").attr("x", 0).attr("dx", "0.15em").attr("dy", "0.9em").text(text);
            }

            if (this.getBBox().height > height && words.length) {
                text = d3.select(this).select(function () {
                    return this.lastChild;
                }).text();
                text = text + "...";
                d3.select(this).select(function () {
                    return this.lastChild;
                }).text(text);
                d3.select(this).classed("wordwrapped", true);

                break;
            }

            line = new Array();
        }
    }

    this.firstChild.data = '';
}
