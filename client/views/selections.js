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
        case "matrix_exports":
            return new Handlebars.SafeString(Template.matrix_exports_mode(this));
        case "country_vs_country":
            return new Handlebars.SafeString(Template.country_vs_country_mode(this));
        case "lang_vs_lang":
            return new Handlebars.SafeString(Template.language_vs_language_mode(this));
    }
}

// Change selected based on session variables
/* The below code also sets uniform on each element individually
 Setting them at a parent template will cause the errors we saw before
 This is equivalent to $(item).val(blah)
                       $(item).uniform()
*/

Template.select_country.rendered = function() {
    $(this.find("select")).val(Session.get("country")).uniform();
    // $(this.find("select")).val(Session.get("country")).chosen({width: "60%"});
}

Template.select_countryX.rendered = function() {
    $(this.find("select")).val(Session.get("countryX")).uniform();
}

Template.select_countryY.rendered = function() {
    $(this.find("select")).val(Session.get("countryY")).uniform();
}

Template.select_language.rendered = function() {
    $(this.find("select")).val(Session.get("language")).uniform();
}

Template.select_languageX.rendered = function() {
    $(this.find("select")).val(Session.get("languageX")).uniform();
}

Template.select_languageY.rendered = function() {
    $(this.find("select")).val(Session.get("languageY")).uniform();
}

Template.select_domain.rendered = function() {
    $(this.find("select")).val(Session.get("domain")).uniform();
}

// TODO: Find closest round number
Template.select_from.rendered = function() {
    $(this.find("select")).val(Session.get("from")).uniform();
}

Template.select_to.rendered = function() {
    $(this.find("select")).val(Session.get("to")).uniform();
}

Template.select_l.rendered = function() {
    $(this.find("select")).val(Session.get("langs")).uniform();
}

Template.select_gender.rendered = function() {
    $(this.find("select")).val(Session.get("gender")).uniform();
}

Template.select_country_order.rendered = function() {
    $(this.find("select")).val(Session.get("countryOrder")).uniform();
}

Template.select_industry_order.rendered = function() {
    $(this.find("select")).val(Session.get("industryOrder")).uniform();
}

// TODO: Do this correctly and reduce redundancy
// TODO: How do you get this tracking correctly?

/* My idea:
   If you're going to do it this way, don't copy the same code 9 times :)
    However, the way I would do it is to cut the current value out of the right part of the route (as an integer index)
     and then just update the router to the new route. This will set session variables as a side effect.

    Your current approach is going to be setting session variables twice.
 */
Template.select_country.events = {
    "change select": function(d) {
        console.log(d)
        var path = window.location.pathname.split('/');
        if (IOMapping[Session.get("vizMode")]["in"].indexOf("country") == 0)
            path[3] = d.target.value;
        else
            path[4] = d.target.value; 

        path[3] = d.target.value;
        Router.go(path.join('/'));
    }
}

Template.select_countryX.events = {
    "change select": function(d) {
        var path = window.location.pathname.split('/');
        path[3] = d.target.value;
        Router.go(path.join('/'));
    }
}

Template.select_countryY.events = {
    "change select": function(d) {
        var path = window.location.pathname.split('/');
        path[4] = d.target.value;
        Router.go(path.join('/'));
    }
}

Template.select_language.events = {
    "change select": function(d) {
        var path = window.location.pathname.split('/');
        if (IOMapping[Session.get("vizMode")]["in"].indexOf("language") == 0)
            path[3] = d.target.value;
        else
            path[4] = d.target.value;    
        Router.go(path.join('/'));
    }
}

Template.select_languageX.events = {
    "change select": function(d) {
        var path = window.location.pathname.split('/');
        path[3] = d.target.value;
        Router.go(path.join('/'));
    }
}

Template.select_languageY.events = {
    "change select": function(d) {
        var path = window.location.pathname.split('/');
        path[4] = d.target.value;
        Router.go(path.join('/'));
    }
}

Template.select_domain.events = {
    "change select": function(d) {
        var path = window.location.pathname.split('/');

        if (IOMapping[Session.get("vizMode")]["in"].indexOf("domain") == 0)
            path[3] = d.target.value;
        else
            path[4] = d.target.value;        
        
        Router.go(path.join('/'));
    }
}

Template.select_from.events = {
    "change select": function(d) {
        var path = window.location.pathname.split('/');
        path[5] = d.target.value;
        Router.go(path.join('/'));
    }
}

Template.select_to.events = {
    "change select": function(d) {
        var path = window.location.pathname.split('/');
        path[6] = d.target.value;
        Router.go(path.join('/'));
    }
}

Template.select_l.events = {
    "change select": function(d) {
        var path = window.location.pathname.split('/');
        path[7] = d.target.value;
        Router.go(path.join('/'));
    }
}

Template.select_gender.events = {
    "change select": function(d) {
        Session.set("gender", d.target.value);
    }
}

Template.select_country_order.events = {
    "change select": function(d) {
        Session.set("countryOrder", d.target.value);
    }
}

Template.select_industry_order.events = {
    "change select": function(d) {
        Session.set("industryOrder", d.target.value);
    }
}

Template.country_dropdown.countries = function (){
    return Countries.find( {},
        { sort: { "countryName": 1 } }
    );
};

Template.language_dropdown.languages = function (){
    return Languages.find( {},
        { sort: { "languageName": 1 } }
    );
};