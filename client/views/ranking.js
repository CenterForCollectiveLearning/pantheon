Template.ranking_table.rendered = function() {
    //initializations

    $('#ranking').dataTable({
        "iDisplayLength": 25,
        "fnDrawCallback": function ( oSettings ) {
            var that = this;
            // Redo for sorted AND filtered...
            // if ( oSettings.bSorted || oSettings.bFiltered )
            // Only redo for sorted, not filtered (ie. you can search/filter and ranking stays stable)
            if ( oSettings.bSorted)
            {
                this.$('td:first-child', {"filter":"applied"}).each( function (i) {
                    that.fnUpdate( i+1, this.parentNode, 0, false, false );
                } );
            }
        },
        "aoColumnDefs": [
            { "bSortable": false, "aTargets": [ 0 ] }
        ],
        "aaSorting": [[ 6, 'desc' ]]
    });

}

Template.ranking_accordion.rendered = function() {

    var mapping = {
        "countries": 0,
        "people": 1,
        "domains": 2
    }

    var accordion = $(".accordion");

    accordion.accordion({
        active: mapping[Session.get("entity")],
        collapsible: false,
        heightStyle: "content",
        fillSpace: false
    });

    accordion.accordion("resize");
}

Template.ranking_accordion.events = {
    "click h3": function (d) {
        var srcE = d.srcElement ? d.srcElement : d.target;
        var option = $(srcE).attr("id");

        var modeToEntity = {
            "country_ranking": "countries"
            , "people_ranking": "people"
            , "domains_ranking": "domains"
        }

        // Reset parameters for a viz type change
        var path = '/ranking/' +
            modeToEntity[option] + '/' +
            defaults.country + '/' +
            defaults.domain + '/' +
            defaults.from + '/' +
            defaults.to
        Router.go(path);
    }
}

Template.ranking_table.render_table = function() {
    var entity = Session.get("entity");
    switch (entity) {
        case "countries":
            return new Handlebars.SafeString(Template.ranked_countries(this));
            break;
        case "people":
        case "domains":
            return new Handlebars.SafeString(Template.ranked_people_list(this));
            break;
    }
}

Template.ranking_table.render_cols = function() {
    var entity = Session.get("entity");
    switch (entity) {
        case "countries":
            return new Handlebars.SafeString(Template.country_cols(this));
        case "people":
            return new Handlebars.SafeString(Template.ppl_cols(this));
        case "domains":
            return new Handlebars.SafeString(Template.ppl_cols(this));;
    }
}

Template.ranked_people_list.people_full_ranking = function() {
    return PeopleTopN.find();
}

Template.ranked_people_list.rank = function() {
    var rank = 1; // the rank gets populated by datatables?
    return rank;
}

Template.ranked_ppl.occupation = function() {
    return this.occupation.capitalize();
}