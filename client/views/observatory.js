// Helper methods for observatory page

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
            collapsible: true,
            heightStyle: "content",
            fillSpace: true
        });

    accordion.accordion( "resize" );
}

Template.accordion.events = {
    "click li a": function (d) {

        var srcE = d.srcElement ? d.srcElement : d.target;
        var option = $(srcE).attr("id");

        var mapping = {
            "country_exports": "treemap",
            "country_imports": "treemap",
            "domain_exports_to": "treemap",
            "domain_imports_from": "treemap",
            "bilateral_exporters_of": "treemap",
            "country_exports": "treemap",
            "matrix_exports": "matrix",
            "country_vs_country": "scatterplot",
            "lang_vs_lang": "scatterplot"
        }

        // Resetting the set by doing a new route navigation
        var url = '/' + 
            mapping[option] + '/' + 
            option + '/' +
            Session.get('country') + '/' +
            Session.get('language') + '/' +
            Session.get('from') + '/' +
            Session.get('to') + '/' +
            Session.get('langs');
        Router.go(url);
    }
}

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

function assignEventListeners() {
    $("#play-explore.paused").live("mouseover", function(e) {
        $('#play-explore').attr('src', 'images/cycle-over.png');
    });

    $("#play-explore.paused").live("mouseout", function(e) {
        $('#play-explore').attr('src', 'images/cycle.png');
    });

    $("#play-explore.playing").live("mouseover", function(e) {
        $('#play-explore').attr('src', 'images/cyclepause-over.png');
    });

    $("#play-explore.playing").live("mouseout", function(e) {
        $('#play-explore').attr('src', 'images/cyclepause.png');
    });


    $("#play-explore").toggle(function(e) {
        $('#play-explore').attr('src', 'images/cyclepause-over.png');
        $('#play-explore').attr('class', 'playing');

        //first time
        if(from == to) {
            $('#play-explore').attr('src', 'images/cycle-over.png');
            $('#play-explore').attr('class', 'paused');

            return false;
        }

        playing = true;

        from = incrementDate();
        console.log(from);

        $("#from").val(from);
        $.uniform.update();

        updateQuestion();
        getIndividuals();

        if(from == to) {
            $('#play-explore').attr('src', 'images/cycle-over.png');
            $('#play-explore').attr('class', 'paused');

            return false;
        }
        //end first time

        inter = self.setInterval(function() {
            if(from >= to) {
                //after we're done
                playing = false;
                $('#play-explore').attr('src', 'images/cycle-over.png');
                $('#play-explore').attr('class', 'paused');

                clearInterval(inter);
            }

            from = incrementDate();
            console.log(from);

            if(from > to) from = to;

            $("#from").val(from);
            $.uniform.update();

            updateQuestion();
            getIndividuals();
        }, play_button_delay);

        return false;
    }, function(e) {
        console.log("toggle pause");

        clearInterval(inter);
        playing = false;

        $('#play-explore').attr('src', 'images/cycle-over.png');
        $('#play-explore').attr('class', 'paused');
    });

    $("#viz_pane svg").on("mouseleave", function () {
        $("#tooltip").fadeOut();
    });

    $("h3 a").on("click", function () {
        return false;
    });

    $('.legend .pill').live('mouseover', function (d) {
        var srcE = d.srcElement ? d.srcElement : d.target;
        var id = srcE.id;

        var color = $(".cell_" + id + " rect").css("fill");
        $(".cell_" + id + " rect").css("fill", d3.hsl(color).brighter(0.7).toString());
        $(this).css("border-bottom", "3px solid #f1f1f1");
    });

    $('.legend .pill').live('mouseout', function (d) {
        var srcE = d.srcElement ? d.srcElement : d.target;
        var id = srcE.id;

        var color = $(".cell_" + id + " rect").css("fill");
        $(".cell_" + id + " rect").css("fill", d3.hsl(color).darker(0.7).toString());
        $(this).css("border-bottom", "0");
    });
}

// Generate question given viz type
Template.question.helpers({
    question: function() {
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

        switch (Session.get("vizMode")) {
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
        }

    }        
  
})
