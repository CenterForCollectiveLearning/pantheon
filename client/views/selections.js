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

Template.select_exporter.countries = function (){
    return Countries.find( {},
        { sort: { "countryName": 1 } }
    );
};