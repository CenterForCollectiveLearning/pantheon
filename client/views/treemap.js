Template.treemap.dataReady = function() {
    NProgress.inc();
    return Session.get("dataReady");
}

// Green, red, brown, yellow, beige, pink, blue, orange

var color_domains = d3.scale.ordinal()
    .domain(["INSTITUTIONS", "ARTS", "HUMANITIES", "BUSINESS & LAW", "EXPLORATION", "PUBLIC FIGURE", "SCIENCE & TECHNOLOGY", "SPORTS"])
    .range(["#468966", "#8e2800", "#864926", "#ffb038", "#fff0a5", "#bc4d96", "#1be6ef", "#ff5800"]);

var treeProps = {
    width: 700,
    height: 560
};

Template.treemap_svg.properties = treeProps;

// var color_domains = d3.scale.ordinal()
//     .domain(["INSTITUTIONS", "ARTS", "HUMANITIES", "BUSINESS & LAW", "EXPLORATION", "PUBLIC FIGURE", "SCIENCE & TECHNOLOGY", "SPORTS"])
//     .range(["#ECD078", "#D95B43", "#43c1d9", "#C02942", "#546c97", "#d278c2", "#53a9f1", "#79BD9A"]);

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
    var data = Treemap.find().fetch();
    console.log("UNFLATTENED DATA:")
    console.log(data);
    var attrs = {};
    var vizMode = Session.get('vizMode');

    if(vizMode === 'country_exports' || vizMode === 'country_imports' || vizMode === 'bilateral_exporters_of'){
        var attr = Domains.find().fetch();
        attr.forEach(function(a){
            var dom = a.domain;
            var ind = a.industry;
            var occ = a.occupation;
            var dom_color = color_domains(dom.toUpperCase());
            var domDict = {
                id: dom
                , name: dom
            };
            var indDict = {
                id: ind
                , name: ind
            };
            var occDict = {
                id: occ
                , name: occ
            };
            attrs[dom] = {
                id: dom
                , name: dom
                , color: dom_color
                , nesting_1: domDict
            };
            attrs[ind] = {
                id: ind
                , name: ind
                , color: dom_color
                , nesting_1: domDict
                , nesting_3: indDict
            };
            attrs[occ] = {
                id: occ
                , name: occ
                , color: dom_color
                , nesting_1: domDict
                , nesting_3: indDict
                , nesting_5: occDict
            };
        });

        var flat = [];
        data.forEach(function(d){
            flat.push({"id": d.occupation, "name": d.occupation, "num_ppl": d.count, "year":2000});  //use a dummy year here for now ...
        });

        console.log("ATTRS:");
        console.log(attrs);
        console.log("DATA:")
        console.log(flat);

        viz
            .type("tree_map")
    //        .dev(true)
            .tooltip_info({})
            .width($('.page-middle').width())
            .height($('.page-middle').height())
            .id_var("id")
            .attrs(attrs)
            .text_var("name")
            .value_var("num_ppl")
            .total_bar({"prefix": "Total Exports: ", "suffix": " individuals"})
            .nesting(["nesting_1","nesting_3","nesting_5"])
            .depth("nesting_3")
            .font("Open Sans")
            .font_weight("300")
            .color_var("color");

        d3.select(context.find("svg"))
            .datum(flat)
            .call(viz);
    } else if(vizMode === 'domain_exports_to'){
        var attr = Countries.find().fetch();
        attr.forEach(function(a){
            var continent = a.continentName;
            var countryCode = a.countryCode;
            var countryName = a.countryName;
            var continent_color = color_countries(continent);
            var continentDict = {
                id: continent
                , name: continent
            };
            var countryDict = {
                id: countryCode
                , name: countryName
            };
            attrs[continent] = {
                id: continent
                , name: continent
                , color: continent_color
                , nesting_1: continentDict
            };
            attrs[countryCode] = {
                id: countryCode
                , name: countryName
                , color: continent_color
                , nesting_1: continentDict
                , nesting_3: countryDict
            };
        });

        var flat = [];
        data.forEach(function(d){
            flat.push({"id": d.countryCode, "name": d.countryName, "num_ppl": d.count, "year":2000});  //use a dummy year here for now ...
        });

        console.log("ATTRS:");
        console.log(attrs);
        console.log("DATA:")
        console.log(flat);

        viz
            .type("tree_map")
            //        .dev(true)
            .tooltip_info({})
            .width($('.page-middle').width())
            .height($('.page-middle').height())
            .id_var("id")
            .attrs(attrs)
            .text_var("name")
            .value_var("num_ppl")
            .total_bar({"prefix": "Total Exports: ", "suffix": " individuals"})
            .nesting(["nesting_1","nesting_3"])
            .depth("nesting_3")
            .font("Open Sans")
            .font_weight("300")
            .color_var("color");

        d3.select(context.find("svg"))
            .datum(flat)
            .call(viz);
    } else if(vizMode === 'domain_imports_from' || vizMode === 'bilateral_importers_of'){
        var attr = Languages.find().fetch();
        attr.forEach(function(a){
            var family = a.lang_family;
            var langCode = a.lang;
            var langName = a.lang_name;
            var family_color = color_languages(family);
            var familyDict = {
                id: family
                , name: family
            };
            var langDict = {
                id: langCode
                , name: langName
            };
            attrs[family] = {
                id: family
                , name: family
                , color: family_color
                , nesting_1: familyDict
            };
            attrs[langCode] = {
                id: langCode
                , name: langName
                , color: family_color
                , nesting_1: familyDict
                , nesting_3: langDict
            };
        });

        var flat = [];
        data.forEach(function(d){
            flat.push({"id": d.lang, "name": d.lang_name, "num_ppl": d.count, "year":2000});  //use a dummy year here for now ...
        });

        console.log("ATTRS:");
        console.log(attrs);
        console.log("DATA:")
        console.log(flat);

        console.log("WIDTH", $('.page-middle').width());
        console.log("HEIGHT", $('.page-middle').height());
        viz
            .type("tree_map")
            //        .dev(true)
            .tooltip_info({})
            .width($('.page-middle').width())
            .height($('.page-middle').height())
            .id_var("id")
            .attrs(attrs)
            .text_var("name")
            .value_var("num_ppl")
            .total_bar({"prefix": "Total: ", "suffix": " Wikipedia Pages"})
            .nesting(["nesting_1","nesting_3"])
            .depth("nesting_3")
            .font("Lato")
            .font_weight(400)
            //.font_size("1.2em")
            .color_var("color");

        console.log(context);
        d3.select(context.find("svg"))
            .datum(flat)
            .call(viz);
    };

    // Overriding d3+ tooltips

    //  d3.selectAll("rect").on("mouseover", mouseover);
    // d3.selectAll("rect").on("mouseout", mouseout);

    // function mouseover(p) {
    //     var country_code = countries[p.y];
    //     var industry = industries[p.x];
    //     var individuals = grouped_individuals[country_code][industry];

    //     Session.set("showTooltip", true);

    //     Template.tooltip.position = position;
    //     Template.tooltip.individuals = individuals;
    //     Template.tt_list.categoryA = country[country_code];
    //     Template.tt_list.categoryB = industry;
    //     if($(window).width() >= d3.event.pageX + 150 + 30 + $("#tooltip").width()) {
    //         $("#tooltip").css("left", (d3.event.pageX + 90) + "px").css("top", (d3.event.pageY - 95) + "px");
    //     } else {
    //         $("#tooltip").show().css("left", (d3.event.pageX - 150 - $("#tooltip").width()) + "px").css("top", (d3.event.pageY - 65) + "px").css("padding", "15px");
    //     }        
    //     $("#tooltip").show()       
    // }

    // function mouseout(p) {
    //     Session.set("showTooltip", false);
    // }
    
//    d3.selectAll(".leaf rect").on("mouseover", function (d) {
//        // TODO generalize this for other treemaps later
//
//        Session.set("tooltipIndustry", d._id);
//
//        $("#tooltip").css("left", (d3.event.pageX + 90) + "px").css("top", (d3.event.pageY - 95) + "px");
//    });
}
