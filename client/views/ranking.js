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

    $("th").on({
        mousemove: function(e) {
            var x = e.pageX;
            var y = e.pageY;
            var se = e.srcElement || e.target;
            var content = e.srcElement.getAttribute("name");
            document.getElementById('tooltip').innerHTML = content;
            window.lastX = e.pageX;
            window.lastY = e.pageY;
            var ttOffset = 10;
            var lastX = window.lastX + ttOffset;
            var lastY = window.lastY + ttOffset;
            var tt = document.getElementById('tooltip');
            tt.className = "visible";
            tt.style.left = lastX + "px";
            tt.style.top  = lastY + "px";
            tt.style.fontSize = "10pt";
            tt.style.zIndex = "100";
        }
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
            defaults.category + '/' +
            defaults.from + '/' +
            defaults.to
        Router.go(path);
    }
}

Template.ranking_table.render_table = function() {
    var entity = Session.get("entity");
    switch (entity) {
        case "countries":
            return new Handlebars.SafeString(Template.ranked_countries_list(this));
            break;
        case "people":
            return new Handlebars.SafeString(Template.ranked_people_list(this));
            break;
        case "domains":
            return new Handlebars.SafeString(Template.ranked_domains_list(this));
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
            return new Handlebars.SafeString(Template.dom_cols(this));;
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

Template.ranked_countries_list.countries_full_ranking = function(){
    return CountriesRanking.find();
}

Template.ranked_countries_list.rank = function(){
    return 1;
}

Template.ranked_domains_list.domains_full_ranking = function(){
    return DomainsRanking.find();
}

Template.ranked_domains_list.rank = function(){
    return 1;
}

// TODO: do this with CSS instead??

Template.ranked_domain.occupation = function() {
    return this.occupation.capitalize();
}

Template.ranked_domain.industry = function() {
    return this.industry.capitalize();
}

Template.ranked_domain.domain = function() {
    return this.domain.capitalize();
}

Template.ranking_table.events = {
    "mouseleave th": function(d) {
        document.getElementById('tooltip').className="invisible";
    }
}