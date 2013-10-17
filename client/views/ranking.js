Template.ranking_table.rendered = function() {
    //initializations
    // $("select, input, a.button, button").uniform();

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

    // $.uniform.update();
}

Template.ranking_accordion.rendered = function() {

    // TODO Make such mappings global...or do something about it
    var mapping = {
        "countries": 0,
        "people": 1,
        "domains": 2
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