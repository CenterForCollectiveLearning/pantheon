// TODO Why is scatterplot.rendered running if this is not ready?
Template.scatterplot.dataReady = function() {
	console.log(Session.get("scatterplotReady"));
	console.log(Scatterplot.find().fetch().length);
    return Session.get("scatterplotReady");
}

// TODO Namespace these

var scatterplotProps = {
	width: 725,
	height: 560
};

var color_domain = d3.scale.ordinal()
.domain(["INSTITUTIONS", "ARTS", "HUMANITIES", "BUSINESS & LAW", "EXPLORATION", "PUBLIC FIGURE", "SCIENCE & TECHNOLOGY", "SPORTS"])
.range(["#ECD078", "#D95B43", "#43c1d9", "#C02942", "#546c97", "#d278c2", "#53a9f1", "#79BD9A"]);

Template.scatterplot_svg.properties = scatterplotProps;

// Aggregate without summing bottom level (people at bottom)
var aggregate = function (obj, values, context) {
	if (!values.length)
		return obj;
	var byFirst = _.groupBy(obj, values[0], context),
	rest = values.slice(1);
	for (var prop in byFirst) {
		byFirst[prop] = aggregate(byFirst[prop], rest, context);
	}
	return byFirst;
};

// Aggregate to bottom level, then sum
var aggregateCounts = function (obj, values) {
	if (!values.length)
		return obj.length;
	var byFirst = _.groupBy(obj, values[0]),
	rest = values.slice(1);
	for (var prop in byFirst) {
		byFirst[prop] = aggregateCounts(byFirst[prop], rest);
	}
	return byFirst;
};


Template.scatterplot_svg.rendered = function() {
	var context = this;
    if( this.rendered ) return;
    this.rendered = true;
	var viz = vizwhiz.viz();

	var occCounts = {};
	var data = [];
	var attrs = {};
	/*
	    Get values for all occupations in two countries
	 */
	var countryX = Session.get('countryX');
	var countryY = Session.get('countryY');
	var countryXName = country[countryX];
	var countryYName = country[countryY];
	var people = Scatterplot.find().fetch();
	var industryCounts = aggregateCounts(people, ['countryCode', 'occupation']);
	var countryXCounts = industryCounts[countryX];
	var countryYCounts = industryCounts[countryY];

	/*
	    Flatten data
	*/
	for (occ in countryXCounts) {
		var valX = countryXCounts[occ];
		var valY = 0.001;
		// If occ in Y, add in Y value
		if (countryYCounts.hasOwnProperty(occ)) {
			valY = countryYCounts[occ];
		}
		// Otherwise Y value is 0
		occCounts[occ] = {
			x: valX
			, y: valY
		}
	}
	for (occ in countryYCounts) {
		var valY = countryYCounts[occ];
		var valX = 0.001;
		if (occ == 'EXPLORER') {
			occ = 'EXPLORER_OCC';
		}
		// If occ not in X, add it in
		if (countryXCounts.hasOwnProperty(occ)) {
			occCounts[occ]['y'] = valY;
		} else {
			occCounts[occ] = {
				x: valX
				, y: valY
			}
		}
	}

	for (var occ in occCounts) {
		var d = {
			id: occ
			, active1: true
			, active2: true
			, year: 2002};
		if (occ == 'EXPLORER') {
			occ = 'EXPLORER_OCC';
		}
		d[countryXName] = occCounts[occ].x
		d[countryYName] = occCounts[occ].y
		d['total'] = occCounts[occ].x + occCounts[occ].y
		data.push(d);                    
	}

	/*
	    Attributes
	*/
	for (var i = people.length - 1; i >= 0; i--) {
		var dom = people[i]['domain'];
		var ind = people[i]['industry'];
		var occ = people[i]['occupation'];
		if (occ == 'EXPLORER' || occ == 'EXPLORATION') {
			occ = 'EXPLORER_OCC';
		}
		var dom_color = color_domain(dom);
		var domDict = {
			id: dom
			, name: dom
		};
		var indDict = {
			id: ind
			, name: ind
		};
		var occDict = {
			id: occ
			, name: occ
		};
		attrs[dom] = {
			id: dom
			, name: dom
			, color: dom_color
			, text_color: dom_color
			, nesting_dom: domDict
		}
		attrs[ind] = {
			id: ind
			, name: ind
			, color: dom_color
			, text_color: dom_color
			, nesting_dom: domDict
			, nesting_ind: indDict
		}
		attrs[occ] = {
			id: occ
			, name: occ
			, color: dom_color
			, text_color: dom_color
			, nesting_dom: domDict
			, nesting_ind: indDict
			, nesting_occ: occDict
		}
	};

	text_formatting = function(d) {
		return d.charAt(0).toUpperCase() + d.substr(1);
	}
	inner_html = function(obj) {
		return "This is some test HTML";
	}

	console.log(data);

	viz
	    .type("pie_scatter")
	    // .dev(true)
	    .width($('.page-middle').width() - 20)
	    .height($('.page-middle').height() - 20)
	    .id_var("id")
	    .attrs(attrs)
	    .text_var("name")
	    .xaxis_var(countryXName)
	    .yaxis_var(countryYName)
	    .value_var("total")
        .nesting(["nesting_dom", "nesting_ind", "nesting_occ"])
        .depth("nesting_ind")
        .text_format(text_formatting)
        .spotlight(false)
        .active_var("active1")
        .click_function(inner_html)
        .background("rgba(0,0,0,0)")
        .font("Lato")
        .font_weight(400)
        .mirror_axis(false)

    d3.select(context.find("svg"))
        .datum(data)
        .call(viz)

}