// Helper methods for observatory page

Template.sharing_options.rendered = function() {
    // Google Plus
    var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
    po.src = 'https://apis.google.com/js/plusone.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);

    // Twitter
    var d = document;
    var s = 'script';
    var id = 'twitter-wjs';

    var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';
    if (!d.getElementById(id)) {
        js=d.createElement(s);
        js.id=id;
        js.src=p+'://platform.twitter.com/widgets.js';
        fjs.parentNode.insertBefore(js,fjs);
    }
}

// Re-render visualization template on window resize
Template.visualization.resize = function() {
    Session.get("resize");
}

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
        case "map":
            return new Handlebars.SafeString(Template.map(this));
        }
}

Template.time_slider.rendered = function() {
    $('select#from, select#to').selectToUISlider({
        labels: 15
        , tooltip: false
    });
}

Template.accordion.rendered = function() {

    // TODO Make such mappings global...or do something about it
    var mapping = {
        "treemap": 0,
        "matrix": 1,
        "scatterplot": 2,
        "map": 3
    }

    var accordion = $(".accordion");

    accordion.accordion({
            active: mapping[Session.get("vizType")],
            collapsible: false,
            heightStyle: "content",
            fillSpace: false
        });

    accordion.accordion("resize");
}

Template.accordion.events = {
    "click li a": function (d) {

        var srcE = d.srcElement ? d.srcElement : d.target;
        var option = $(srcE).attr("id");

        var modeToType = {
            "country_exports": "treemap"
            , "country_imports": "treemap"
            , "domain_exports_to": "treemap"
            , "domain_imports_from": "treemap"
            , "bilateral_exporters_of": "treemap"
            , "bilateral_importers_of": "treemap"
            , "matrix_exports": "matrix"
            , "country_vs_country": "scatterplot"
            , "lang_vs_lang": "scatterplot"
            , "domain_vs_domain": "scatterplot"
            , "map": "map"
        }

        // Parameters depend on vizMode (e.g countries -> languages for exports)
        var param1 = IOMapping[option]["in"][0];
        var param2 = IOMapping[option]["in"][1];

        // Reset parameters for a viz type change
        var path = '/' +
            modeToType[option] + '/' + 
            option + '/' +
            defaults[param1] + '/' +  // First input (e.g. exporter country)
            defaults[param2] + '/' +  // Second input (e.g. importer lang)
            defaults.from + '/' +  // From
            defaults.to + '/' +  // To
            defaults.langs + '/';  // Langs
        Router.go(path);
    }
}

// Global helper for data ready
Handlebars.registerHelper("dataReady", function(){
    console.log("DATA READY");
    return Session.get("dataReady");
});

Handlebars.registerHelper("initialDataReady", function(){
    return Session.get("initialDataReady");
});

Handlebars.registerHelper("tooltipDataReady", function(){
    return Session.get("tooltipDataReady");
});

// Create a global helper
// Use this from multiple templates
Handlebars.registerHelper("person_lookup", function(){
    return People.findOne(this._id);
});

Template.ranked_list.top10 = function() {
    return PeopleTop10.find({}, {sort: {numlangs: -1}})
}

Template.ranked_list.empty = function(){
    return PeopleTop10.find().count() === 0;
}

Template.ranked_person.birthday = function() {
    var birthday = (this.birthyear < 0) ? (this.birthyear * -1) + " B.C." : this.birthyear;
    return birthday;
}

Template.date_header.helpers({
    from: function() { 
        var from = Session.get("from"); 
        return (from < 0) ? (from * -1) + " B.C." : from; 
    }
    , to: function() { 
        var to = Session.get("to");
        return (to < 0) ? (to * -1) + " B.C." : to; 
    }
});

// Generate question given viz type
Template.question.question = function() {
    try {
        var s_countries = (Session.get("country") == "all") ? "the world" : Countries.findOne({countryCode: Session.get("country")}).countryName;
        var s_countryX = (Session.get("countryX") == "all") ? "the world" : Countries.findOne({countryCode: Session.get("countryX")}).countryName;
        var s_countryY = (Session.get("countryY") == "all") ? "the world" : Countries.findOne({countryCode: Session.get("countryY")}).countryName;
        var s_domains = (Session.get("category") == "all") ? "all domains" : decodeURIComponent(Session.get("category"));
        var s_domainX = (Session.get("categoryX") == "all") ? "all domains" : decodeURIComponent(Session.get("categoryX"));
        var s_domainY = (Session.get("categoryY") == "all") ? "all domains" : decodeURIComponent(Session.get("categoryY"));
        var s_regions = (Session.get("language") == "all") ? "the world" : Languages.findOne({lang: Session.get("language")});
        var s_languageX = Languages.findOne({lang: Session.get("languageX")});
        var s_languageY = Languages.findOne({lang: Session.get("languageY")});
        var does_or_do = (Session.get("country") == "all") ? "do" : "does";
        var s_or_no_s_c = (Session.get("country") == "all") ? "'" : "'s";
        var s_or_no_s_r = (Session.get("language") == "all") ? "'" : "'s";
        var speakers_or_no_speakers = (Session.get("language") == "all") ? "" : " speakers";
    
    var gender;
    var gender_var = Session.get("gender");
    switch (gender_var) {
        case "both":
            gender = 'men and women';
            break;
        case "male":
            gender = 'men';
            break;
        case "female":
            gender = 'women';
            break;
        case "ratio":
            gender = 'ratio of women to men';
            break;
    }

    // TODO Make this not suck
    if(s_domains.charAt(0) == "-") {
        console.log(s_domains.charAt(s_domains.length-1));
        if(s_domains.charAt(s_domains.length-1) == "y")
            s_domains = s_domains.substring(1, s_domains.length-1) + "ies";
        else
            s_domains = s_domains.substring(1) + "s";
    }
    else if(s_domains.charAt(0) == "+") {
        // s_domains = "in the area of " + s_domains.substring(1);
        s_domains = s_domains.substring(1);
    } 
    if(s_domainX.charAt(0) == "-") {
        console.log(s_domainX.charAt(s_domainX.length-1));
        if(s_domainX.charAt(s_domainX.length-1) == "y")
            s_domainX = s_domainX.substring(1, s_domainX.length-1) + "ies";
        else
            s_domainX = s_domainX.substring(1) + "s";
    }
    if(s_domainY.charAt(0) == "-") {
        console.log(s_domainY.charAt(s_domainY.length-1));
        if(s_domainY.charAt(s_domainY.length-1) == "y")
            s_domainY = s_domainY.substring(1, s_domainY.length-1) + "ies";
        else
            s_domainY = s_domainY.substring(1) + "s";
    }
    if(s_domainX.charAt(0) == "+") {
        // s_domain = "in the area of " + s_domain.substring(1);
        s_domainX = s_domainX.substring(1);
    }
    if(s_domainY.charAt(0) == "+") {
        // s_domain = "in the area of " + s_domain.substring(1);
        s_domainY = s_domainY.substring(1);
    }

    function boldify(s) {
        return "<b>" + s + "</b>";
    }

    var mode = Session.get("vizMode");
    switch (mode) {
        case "country_exports":
            return new Handlebars.SafeString("What are the cultural exports of " + boldify(s_countries) + "?");
        case "country_imports":
            return new Handlebars.SafeString((Session.get("language") == "all") ? "What does " + boldify("the world") + " import?" : "What do " + boldify(s_regions) + " speakers import?");
        case "domain_exports_to":
            return new Handlebars.SafeString("Who exports " + boldify(s_domains) + "?");
        case "domain_imports_from":
            return new Handlebars.SafeString("Who imports " + boldify(s_domains) + "?");
        case "bilateral_exporters_of":
            return new Handlebars.SafeString("What does " + boldify(s_countries) + " export to " + boldify(s_regions + speakers_or_no_speakers) + "?");
        case "bilateral_importers_of":
            return new Handlebars.SafeString("Where does " + boldify(s_countries) + " export " + boldify(s_domains) + " to?");
        case "matrix_exports":
            return new Handlebars.SafeString("What " + boldify(gender) + " does " + boldify(s_countries) + " export?");
        case "country_vs_country":
            return new Handlebars.SafeString("What does " + boldify(s_countryX) + " export compared to " + boldify(s_countryY) + "?");
        case "lang_vs_lang":
            return new Handlebars.SafeString("What do " + boldify(s_languageX) + " speakers import compared to " + boldify(s_languageY) + " speakers?");
        case "domain_vs_domain":
            return new Handlebars.SafeString("Who exports " + boldify(s_domainX) + " compared to " + boldify(s_domainY) + "?");
        case "map":
            return new Handlebars.SafeString("Who exports " + boldify(s_domains) + "?");
    }
    } catch(e) {}
};

/*
 * TOOLTIPS
 */

Template.tooltip.helpers({
    tooltipShown: function() { return Session.get("showTooltip") }
    , position: function() { return Session.get("tooltipPosition") }
    , top5: function() { return Tooltips.find({_id: {$not: 'count'}}) } // Total count is also passed
    , count: function() {
        var doc = Tooltips.findOne({_id: 'count'});
        return (typeof doc !== "undefined") ? doc.count : 0;
    }
    , suffix: function() {
        var doc = Tooltips.findOne({_id: 'count'});
        return (typeof doc !== "undefined" && doc.count > 1) ? "individuals" : "individual";
    }
    , more: function() { 
        var doc = Tooltips.findOne({_id: 'count'});
        return (typeof doc !== "undefined") ? doc.count > 5 : false;
    }
    , extras: function() { 
        var doc = Tooltips.findOne({_id: 'count'});
        return (typeof doc !== "undefined") ? doc.count - 5 : 0;
    }
})