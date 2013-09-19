// Helper methods for observatory page

// Render SVGs and ranked list based on current vizMode
Template.visualization.render_template = function() {
    var type = Session.get("vizType");
    switch (type) {
        case "treemap":
            return new Handlebars.SafeString(Template.treemap(this));
        case "matrix":
            return new Handlebars.SafeString(Template.matrix(this));
        case "scatterplot":
            return new Handlebars.SafeString(Template.scatterplot(this));
    }
}

Template.accordion.rendered = function() {

    // TODO Make such mappings global...or do something about it
    var mapping = {
        "treemap": 0,
        "matrix": 1,
        "scatterplot": 2
    }

    var accordion = $(".accordion");

    accordion.accordion({
            active: mapping[Session.get("vizType")],
            collapsible: false,
            heightStyle: "content",
            fillSpace: false
        });

    accordion.accordion( "resize" );
}

Template.accordion.events = {
    "click li a": function (d) {

        var srcE = d.srcElement ? d.srcElement : d.target;
        var option = $(srcE).attr("id");

        var modeToType = {
            "country_exports": "treemap",
            "country_imports": "treemap",
            "domain_exports_to": "treemap",
            "domain_imports_from": "treemap",
            "bilateral_exporters_of": "treemap",
            "bilateral_importers_of": "treemap",
            "matrix_exports": "matrix",
            "country_vs_country": "scatterplot",
            "lang_vs_lang": "scatterplot"
        }

        // Parameters depend on vizMode (e.g countries -> languages for exports)
        var mode = Session.get("vizMode");
        var param1 = IOMapping[mode]["in"][0];
        var param2 = IOMapping[mode]["in"][1];

        // Reset parameters for a viz type change
        var path = '/' +
            modeToType[option] + '/' +
            option + '/' +
            defaults.country + '/' +  // First input (e.g. exporter country)
            defaults.language + '/' +  // Second input (e.g. importer lang)
            defaults.from + '/' +  // From
            defaults.to + '/' +  // To
            defaults.langs + '/';  // Langs
        Router.go(path);
    }
}

// Create a global helper
// Use this from multiple templates
Handlebars.registerHelper("person_lookup" ,function(){
    return People.findOne(this._id);
});

Template.ranked_list.top10 = function() {
    return PeopleTop10.find();
}

Template.ranked_list.empty = function(){
    return PeopleTop10.find().count() === 0;
}

Template.ranked_person.birthday = function() {
    var birthday = (this.birthyear < 0) ? (this.birthyear * -1) + " B.C." : this.birthyear;
    return birthday;
}

// Generate question given viz type
Template.question.question = function() {

    var s_countries = (Session.get("country") == "all") ? "the world" : country[Session.get("country")];
    var s_domains = (Session.get("domain") == "all") ? "all domains" : decodeURIComponent(Session.get("domain"));
    var s_regions = (Session.get("language") == "all") ? "the world" : region[Session.get("language")];
    var does_or_do = (Session.get("country") == "all") ? "do" : "does";
    var s_or_no_s_c = (Session.get("country") == "all") ? "'" : "'s";
    var s_or_no_s_r = (Session.get("language") == "all") ? "'" : "'s";
    var speakers_or_no_speakers = (Session.get("language") == "all") ? "" : " speakers";

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

    var mode = Session.get("vizMode");
    switch (mode) {
        case "country_exports":
            return "What does " + s_countries + " export?";
        case "country_imports":
            return (Session.get("language") == "all") ? "What does the world import?" : "What do " + s_regions + " speakers import?";
        case "domain_exports_to":
            return "Who exports " + s_domains + "?";
        case "domain_imports_from":
            return "Who imports " + s_domains + "?";
        case "bilateral_exporters_of":
            return "What does " + s_countries + " export to " + s_regions + speakers_or_no_speakers + "?";
        case "bilateral_importers_of":
            return "Where does " + s_countries + " export " + s_domains + " to?";
        case "matrix_exports":
            return "What does " + s_countries + " export?";
        case "country_vs_country":
            return "What does " + s_countries + " export?";
        case "lang_vs_lang":
            return "What does " + s_countries + " export?";
    }

};

Template.popup_list.suffix = function(){
    return (this.count > 1) ? "individuals" : "individual";
}

Template.popup_list.top5 = function() {
    return Tooltips.find();
}

Template.popup_list.more = function() {
    return this.count > 5;
}

Template.popup_list.extras = function () {
    return this.count - 5;
}