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

Template.slider.rendered = function() {
    // TODO Make all increments equal (make a mapping dictionary?)
    var values = [-1000, -900, -800, -700, -600, -500, -400, -300, -200, -100, 1, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1850, 1900, 1910, 1920, 1930, 1940, 1950, 1960, 1970, 1980, 1990, 2000];
    var slider = $(".slider");
    $(".from").text(Session.get("from"));
    $(".to").text(Session.get("to"));

    slider.slider({
        range: true
        , min: values[0]
        , max: values[values.length-1]
        , step: 10
        , values: [ Session.get("from"), Session.get("to") ]
        // TODO Combine these two event listeners
        , stop: function( event, ui ) {
            // Change routing
            var from = ui.values[0];
            var to = ui.values[1];
            if($.inArray(from, values) > -1 && $.inArray(to, values) > -1) {
                var path = window.location.pathname.split('/');
                path[5] = from;
                path[6] = to;
                Router.go(path.join('/'));
            } else {
                return false;
            }
        }
        , slide: function( event, ui ) {
            // Change showing date range
            var from = ui.values[0];
            var to = ui.values[1];
            if($.inArray(from, values) > -1 && $.inArray(to, values) > -1) {
                $(".from").text(from);
                $(".to").text(to);
            } else {
                return false;
            }
        }
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
            , "lang_vs_lang": "scatterplot"
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

// Generate question given viz tqype
Template.question.question = function() {
    var s_countries = (Session.get("country") == "all") ? "the world" : country[Session.get("country")];
    var s_countryX = country[Session.get("countryX")];
    var s_countryY = country[Session.get("countryY")];
    var s_domains = (Session.get("domain") == "all") ? "all domains" : decodeURIComponent(Session.get("domain"));
    var s_regions = (Session.get("language") == "all") ? "the world" : region[Session.get("language")];
    var s_languageX = region[Session.get("languageX")];
    var s_languageY = region[Session.get("languageY")];
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

    function boldify(s) {
        return "<b>" + s + "</b>";
    }

    var mode = Session.get("vizMode");
    switch (mode) {
        case "country_exports":
            return new Handlebars.SafeString("What does " + boldify(s_countries) + " export?");
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
            return new Handlebars.SafeString("What does " + boldify(s_countries) + " export?");
        case "country_vs_country":
            return new Handlebars.SafeString("What does " + boldify(s_countryX) + " export compared to " + boldify(s_countryY) + "?");
        case "lang_vs_lang":
            return new Handlebars.SafeString("What do " + boldify(s_languageX) + " speakers export compared to " + boldify(s_languageY) + " speakers?");
        case "map":
            return new Handlebars.SafeString("Who exports " + boldify(s_domains) + "?");
    }
};

/*
 * TOOLTIPS
 */
Template.tooltip.tooltipShown = function() {
    return Session.get("showTooltip");
}

Template.tooltip.position = function() {
    return Session.get("tooltipPosition");
}

Template.tooltip.individuals = function() {
    return Session.get("tooltipPeople");
};

Template.tt_list.heading = function() {
    return Session.get("tooltipHeading");
}

Template.tt_list.count = function() {
    return this.length;
}

Template.tt_list.suffix = function() {
    return (this.length > 1) ? "individuals" : "individual";
}

Template.tt_list.top5 = function() {
    return this.slice(0, 5);
}

Template.tt_list.more = function() {
    return this.length > 5;
}

Template.tt_list.extras = function () {
    return this.length - 5;
}