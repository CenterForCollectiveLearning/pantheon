Template.ranking.rendered = function() {
    //initializations
    $("select, input, a.button, button").uniform();

    $('#ranking').dataTable({
        "iDisplayLength": 200,
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

    $.uniform.update();
}