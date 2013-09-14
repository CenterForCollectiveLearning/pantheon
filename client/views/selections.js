Template.select_mode.render_template = function() {
    var mode = Session.get("vizMode");

    switch (mode) {
        case "country_exports":
            return new Handlebars.SafeString(Template.country_exporters_mode(this));
        case "country_imports":
            return new Handlebars.SafeString(Template.country_importers_mode(this));
        case "domain_exports_to":
            return new Handlebars.SafeString(Template.domain_mode(this));
        case "domain_imports_from":
            return new Handlebars.SafeString(Template.domain_mode(this));
        case "bilateral_exporters_of":
            return new Handlebars.SafeString(Template.bilateral_exporters_mode(this));
        case "bilateral_importers_of":
            return new Handlebars.SafeString(Template.bilateral_importers_mode(this));
        case "heatmap_exports":
            return new Handlebars.SafeString(Template.heatmap_exports_mode(this));
    }
}

// Change selected based on session variables
// Template.select_exporter.rendered = function() {
//     $(this.find("select")).val(Session.get("ent1"));
// }

// Template.select_importer.rendered = function() {
//     $(this.find("select")).val(Session.get("ent2"));
// }

// Template.select_domain.rendered = function() {
//     $(this.find("select")).val(Session.get("ent1"));
// }

// TODO: Find closest round number
Template.select_from.rendered = function() {
    $(this.find("select")).val(Session.get("from"));
}

Template.select_to.rendered = function() {
    $(this.find("select")).val(Session.get("to"));
}

Template.select_l.rendered = function() {
    $(this.find("select")).val(Session.get("langs"));
}

// TODO: Do this correctly and reduce redundancy

Template.select_from.events = {
    "change select": function(d) {
        Session.set("from", d.target.value);
        var url = '/' + Session.get('vizType') + '/' + 
            Session.get('vizMode') + '/' +
            Session.get('ent1') + '/' +
            Session.get('ent2') + '/' +
            Session.get('from') + '/' +
            Session.get('to') + '/' +
            Session.get('langs');
        Router.go(url);
    }
}

Template.select_to.events = {
    "change select": function(d) {
        Session.set("to", d.target.value);
        var url = '/' + Session.get('vizType') + '/' + 
            Session.get('vizMode') + '/' +
            Session.get('ent1') + '/' +
            Session.get('ent2') + '/' +
            Session.get('from') + '/' +
            Session.get('to') + '/' +
            Session.get('langs');
        Router.go(url);
    }
}

Template.select_mode.rendered = function() {
//    $.each(this.findAll("select, input"), function() {
//        $(this).uniform();
            //TODO: fix this part
//    });
}

Template.select_exporter.countries = function (){
    return Countries.find( {},
        { sort: { "countryName": 1 } }
    );
};