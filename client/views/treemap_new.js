Template.treemap.dataReady = function() {
    return treemapSub.ready();
}
//
//Template.tooltip.tooltip = function() {
//    return Session.get("tooltipIndustry");
//}
//
//Template.tooltip.tooltip_data = function() {
//    return Domains.findOne({ _id: Session.get("tooltipIndustry") })
//}

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
    var attr = Domains.find().fetch();
    var data = Treemap.find().fetch();

    var attrs = {};

    attr.forEach(function(a){
        var occupation = {};
        occupation["id"] = a.occupation;
        occupation["nesting_1"] = {"name": a.domain, "id": a.domain};
        occupation["nesting_3"] = {"name": a.industry, "id": a.industry};
        occupation["nesting_5"] = {"name": a.occupation, "id": a.occupation};
        occupation["color"] = color_domains(a.domain.toUpperCase());
        attrs[a.occupation] = occupation;
    });

    var flat = [];
    data.forEach(function(d){
       flat.push({"id": d.occupation, "name": d.occupation, "num_ppl": d.count});
    });

    console.log("ATTRS:");
    console.log(attrs);
    console.log("DATA:")
    console.log(flat);



    viz
        .type("tree_map")
        .width(725)
        .height(560)
        .id_var("id")
        .attrs(attrs)
        .text_var("name")
        .value_var("num_ppl")
        .tooltip_info({})
        .total_bar({"prefix": "Total Exports: ", "suffix": " individuals"})
        .nesting(["nesting_1","nesting_3","nesting_5"])
        .depth("nesting_1")
        .font("PT Sans")
        .font_weight("lighter")
        .color_var("color");

    d3.select(context.find("svg"))
        .datum(flat)
        .call(viz);

   /*
    d3.selectAll(".leaf rect").on("mouseover", function (d) {
        // TODO generalize this for other treemaps later

        Session.set("tooltipIndustry", d._id);

        $("#tooltip").css("left", (d3.event.pageX + 90) + "px").css("top", (d3.event.pageY - 95) + "px");
    });
    */
}
