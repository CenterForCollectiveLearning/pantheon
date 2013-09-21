Template.scatterplot.dataReady = function() {
    return allpeopleSub.ready()
}

Template.scatterplot.rendered = function() {
	var viz = vizwhiz.viz();

	var color_domain = d3.scale.ordinal()
    .domain(["INSTITUTIONS", "ARTS", "HUMANITIES", "BUSINESS & LAW", "EXPLORATION", "PUBLIC FIGURE", "SCIENCE & TECHNOLOGY", "SPORTS"])
    .range(["#ECD078", "#D95B43", "#43c1d9", "#C02942", "#546c97", "#d278c2", "#53a9f1", "#79BD9A"]);

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
	var people = People.find().fetch();
	var industryCounts = aggregateCounts(people, ['countryCode', 'occupation']);
	var countryXCounts = industryCounts[countryX];
	var countryYCounts = industryCounts[countryY];

	/*
	    Flat data
	*/
	for (occ in countryXCounts) {
		var valX = countryXCounts[occ];
		var valY = 0;
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
		var valX = 0;
		// If occ not in X, add it in
		if (countryXCounts.hasOwnProperty(occ)) {
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

	viz
	  .width(940)
	  .height(600)
	  .type("pie_scatter")
	  .dev(true)
	  .text_var("name")
	  .id_var("id")
	  .attrs(attrs)
	  .xaxis_var(countryXName)
	  .yaxis_var(countryYName)
	  .value_var("total")
      .tooltip_info([countryXName, countryYName])
      // .total_bar({"prefix": "Export Value: $", "suffix": " USD", "format": ",f"})
      .nesting(["nesting_dom", "nesting_ind", "nesting_occ"])
      // .nesting_aggs({"complexity":"mean","distance":"mean","rca":"mean"})
      .depth("nesting_ind")
      .text_format(text_formatting)
      .spotlight(false)
      // .year(2000)
      .active_var("active1")
      .click_function(inner_html)
      // .solo("11")
      // .static_axis(false)
      .mirror_axis(true)

    d3.select("#viz")
      .datum(data)
      .call(viz)
}