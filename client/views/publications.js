var toc = [
	{name: "The Structure and Dynamics of Global Cultural Development"
	, type: "title"}, [
	    "Abstract"
	    , "Introduction"
	    , "Data and Methods"
	    , "Results"
	], 
	{type: "spacer"},
	{name: "Communication Technologies as Agents of Fame"
	, type: "title"}, [ //: What 11,000 Biographies can tell us about our Collective Memory", [
	    "Abstract"
	    , "Introduction"
	    , "Data and Methods"
	    , "Results"
	]
]

var name_to_id = function (name) {
	var x = name.toLowerCase().replace(/[^a-z0-9_,.]/g, '').replace(/[,.]/g, '_');
	return x;
};

// TODO: Make scrolling work
// TODO: SIMPLIFY THIS CODE!!!
Template.publications.rendered = function() {
	console.log("RENDERING PUBLICATIONS TEMPLATE");

	// TODO How do you get this to re-run?
    $.cachedScript('http://www.readrboard.com/static/engage.js').done(function() {
        console.log( "Received Script" );
    });

    var scrollToSection = function (section) {
        if (! $(section).length)
            return;

        ignore_waypoints = true;
        Session.set("section", section.substr(1));
        scroller().animate({
            scrollTop: $(section).offset().top
        }, 500, 'swing', function () {
            window.location.hash = section;
            ignore_waypoints = false;
        });
    };

    // returns a jQuery object suitable for setting scrollTop to
    // scroll the page, either directly for via animate()
    var scroller = function() {
        return $("div.page-middle").stop();
    };  

    var sections = [];
    _.each($('.publication h1, .publication h2, .publication h3'), function (elt) {
        var classes = (elt.getAttribute('class') || '').split(/\s+/);
        if (_.indexOf(classes, "nosection") === -1)
            sections.push(elt);
    });

    console.log(sections);
  
    for (var i = 0; i < sections.length; i++) {
        // var classes = (sections[i].getAttribute('class') || '').split(/\s+/);
        // console.log(classes);
        // if (_.indexOf(classes, "nosection") !== -1)
        //  continue;
        sections[i].prev = sections[i-1] || sections[i];
        sections[i].next = sections[i+1] || sections[i];
        $(sections[i]).waypoint({offset: 30});
        console.log(sections[i]);
    }

    var section = document.location.hash.substr(1) || sections[0].id;
    Session.set('section', section);
    if (section) {
        // WebKit will scroll down to the #id in the URL asynchronously
        // after the page is rendered, but Firefox won't.
        Meteor.setTimeout(function() {
            var elem = $('#'+section);
            if (elem.length)
                scroller().scrollTop(elem.offset().top);
        }, 0);
    }
  
    var ignore_waypoints = false;
    $('body').delegate('h1, h2, h3', 'waypoint.reached', function (evt, dir) {
        if (!ignore_waypoints) {
            var active = (dir === "up") ? this.prev : this;
            Session.set("section", active.id);
        }
    });
  
    window.onhashchange = function () {
        scrollToSection(location.hash);
    };
    
    $('#main, #nav').delegate("a[href^='#']", 'click', function (evt) {
        evt.preventDefault();
        var sel = $(this).attr('href');
        scrollToSection(sel);
    
        mixpanel.track('docs_navigate_' + sel);
    });
  
    // Make external links open in a new tab.
    $('a:not([href^="#"])').attr('target', '_blank');
}

// TODO: Options if not on that paper
// Convert toc into a list of {id, name, type, depth}
Template.sidenav.sections = function () {
	var ret = [];
	var walk = function (items, depth) {
		_.each(items, function (item) {
			if (item instanceof Array)
				walk(item, depth + 1);
			else {
				if (typeof(item) === "string")
					item = {name: item};
				ret.push(_.extend({
					type: "section",
					id: item.name && name_to_id(item.name) || undefined,
					depth: depth,
				}, item));
			}
		});
	};
	walk(toc, 1);
	console.log(ret);
	return ret;
};

Template.sidenav.type = function (what) {
    return this.type === what;
}

Template.sidenav.maybe_current = function () {
    return Session.equals("section", this.id) ? "current" : "";
};