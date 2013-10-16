// TODO Why is scatterplot.rendered running if this is not ready?
Template.scatterplot.dataReady = function() {
	NProgress.inc();
	console.log("DATAREADY", Session.get("dataReady"));
    return Session.get("dataReady");
}

// TODO Namespace these

var scatterplotProps = {
	width: 725,
	height: 560
};

Template.scatterplot_svg.properties = scatterplotProps;

var color_domains = d3.scale.ordinal()
	.domain(["INSTITUTIONS", "ARTS", "HUMANITIES", "BUSINESS & LAW", "EXPLORATION", "PUBLIC FIGURE", "SCIENCE & TECHNOLOGY", "SPORTS"])
	.range(["#ECD078", "#D95B43", "#43c1d9", "#C02942", "#546c97", "#d278c2", "#53a9f1", "#79BD9A"]);

function isEmpty(obj) {
    for(var prop in obj) {
        if(obj.hasOwnProperty(prop))
            return false;
    }
    return true;
}

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
    // if( this.rendered ) return;
    // this.rendered = true;
	var viz = vizwhiz.viz();

	var occCounts = {};
	var data = [];
	var attrs = {};

	var vizMode = Session.get('vizMode');
	if (vizMode === 'country_vs_country') {
		var x_code = Session.get('countryX');
		var y_code = Session.get('countryY');
		var x_name = Countries.findOne({countryCode: x_code}).countryName;
		var y_name = Countries.findOne({countryCode: y_code}).countryName;

		var people = Scatterplot.find().fetch();
	} else if (vizMode === 'lang_vs_lang') {
		var x_code = Session.get('languageX');
		var y_code = Session.get('languageY');
		var x_name = Languages.findOne({lang: x_code}).lang_name;
		var y_name = Languages.findOne({lang: y_code}).lang_name;

		var people = Scatterplot.find().fetch();

		var industryCounts = aggregateCounts(people, ['countryCode', 'occupation']);
		var x_counts = industryCounts[x_code];
		var y_counts = industryCounts[y_code];
	}

	console.log(people);

	var attr = Domains.find().fetch();
        attr.forEach(function(a){
            var dom = a.domain;
            var ind = a.industry;
            var occ = a.occupation;
            var dom_color = color_domains(dom.toUpperCase());
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
                , nesting_1: domDict
            };
            attrs[ind] = {
                id: ind
                , name: ind
                , color: dom_color
                , nesting_1: domDict
                , nesting_3: indDict
            };
            attrs[occ] = {
                id: occ
                , name: occ
                , color: dom_color
                , nesting_1: domDict
                , nesting_3: indDict
                , nesting_5: occDict
            };
        });
	/*
	    Flatten data
	*/
	// if (typeof x_counts !== 'undefined' && !isEmpty(x_counts)) {
	// 	for (occ in x_counts) {
	// 		var valX = x_counts[occ];
	// 		var valY = 0;
	// 		// Skipping EXPORER for now...
	// 		if (occ == 'EXPLORER') {
	// 			console.log(occ);
 //    			continue;
 //    		}
	// 	    // If Y and occ in Y, add in Y value
	// 	    if (typeof y_counts !== 'undefined' && y_counts.hasOwnProperty(occ)) {
	// 	    	valY = y_counts[occ];
	// 	    }
	// 	    // Otherwise Y value is 0
	// 	    occCounts[occ] = {
	// 	    	x: valX
	// 	    	, y: valY
	// 	    }
	// 	}
	// }
	
	// if (typeof y_counts !== 'undefined' && !isEmpty(y_counts)) {
 //    	for (occ in y_counts) {
 //    		var valY = y_counts[occ];
 //    		var valX = 0;
 //    		if (occ == 'EXPLORER') {
 //    			console.log(occ);
 //    			continue;
 //    		}
 //    		// If X and occ in X, add it in
 //    		if (typeof x_counts !== 'undefined' && x_counts.hasOwnProperty(occ)) {
 //    			occCounts[occ]['y'] = valY;
 //    		} else {
 //    			occCounts[occ] = {
 //    				x: valX
 //    				, y: valY
 //    			}
 //    		}
 //    	}
 //    }

	// for (var occ in occCounts) {
	// 	var d = {
	// 		id: occ
	// 		, active1: true
	// 		, active2: true
	// 		, year: 2002};
	// 	try {
	// 		d[countryXName] = occCounts[occ].x
	// 		d[countryYName] = occCounts[occ].y
	// 		d['total'] = occCounts[occ].x + occCounts[occ].y
	// 		data.push(d);                    
	// 	} catch(e) {}
	// }

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
		var dom_color = color_domains(dom);
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

	viz
	    .type("pie_scatter")
	    // .dev(true)
	    .width($('.page-middle').width() - 20)
	    .height($('.page-middle').height() - 20)
	    .id_var("id")
	    .attrs(attrs)
	    .text_var("name")
	    .xaxis_var(x_name)
	    .yaxis_var(y_name)
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