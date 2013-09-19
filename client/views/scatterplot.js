Template.scatterplot.rendered = function() {
	var viz = vizwhiz.viz();

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
    var aggregate_counts = function (obj, values, context) {
    	if (!values.length)
    		return obj.length;
    	var byFirst = _.groupBy(obj, values[0], context),
    	rest = values.slice(1);
    	for (var prop in byFirst) {
    		byFirst[prop] = aggregate_counts(byFirst[prop], rest, context);
    	}
    	return byFirst;
    };

	Deps.autorun(function() {
		var occs = {};
		/*
	      Get values for all occupations in two countries
		 */
		var countryX = Session.get('countryX');
		var countryY = Session.get('countryY');
		var data = People.find().fetch();
		var industryCounts = aggregate_counts(data, ['countryCode', 'industry']);
		var countryXCounts = industryCounts[countryX];
		var countryYCounts = industryCounts[countryY];


		for (occ in countryXCounts) {
			var valX = countryXCounts[occ];
			var valY = 0;
			// If occ in Y, add in Y value
			if (countryYCounts.hasOwnProperty(occ)) {
				valY = countryYCounts[occ];
			}
			// Otherwise Y value is 0
			occs[occ] = {
				x: valX
				, y: valY
			}
		}

		for (occ in countryYCounts) {
			var valY = countryYCounts[occ];
			var valX = 0;
			// If occ not in X, add it in
			if (countryXCounts.hasOwnProperty(occ)) {
				occs[occ] = {
					x: valX
					, y: valY
				}
			}
		}

		var occArray = [];
		for (var occ in occs) {
			occArray.push({
				"occupation": occ
				, "x": occs[occ].x
				, "y": occs[occ].y
			});
		}

		console.log(occArray);

		viz
          .type("pie_scatter")
          .text_var("name")
          .id_var("id")
          //.attrs(attrs)
          .xaxis_var(countryX)
          .yaxis_var(countryY)
          .value_var("Number of People")
          .tooltip_info(["value"])
          total_bar({"prefix": "Export Value: $", "suffix": " USD", "format": ",f"})
          //.nesting(["nesting_2","nesting_4","nesting_6"])
          //.nesting_aggs({"complexity":"mean","distance":"mean","rca":"mean"})
          //.depth("nesting_2")
          //.text_format(text_formatting)
          .spotlight(false)
          //.year(2003)
          .active_var("active1")
          //.click_function(inner_html)
          // .solo("11")
          // .static_axis(false)
          .mirror_axis(true)

    d3.select("#viz")
      .datum(data)
      .call(viz)
	})
}