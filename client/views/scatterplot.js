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

		/*
		    Flat and attributes data
		*/
		var occArray = [];
		var attrs = {};
		for (var occ in occs) {
			occArray.push({
				"id": occ
				, "active1": true
				, "active2": true
				, "valX": occs[occ].x
				, "valY": occs[occ].y
			});
			attrs[occ] = {
				"active1": true
				, "id": occ
				, "name": occ
				, "color": "FFE999"
				, "text_color": "#4C4C4C"
				, "nesting_occ": {
					"id": occ
					, "name": occ
				}
			}
		}

		console.log(JSON.stringify(occArray));
		console.log(JSON.stringify(attrs));

		text_formatting = function(d) {
			return d.charAt(0).toUpperCase() + d.substr(1);
		}

		d3.json("data/mg_test_data.json", function(flat_data){
			d3.json("data/attr_hs.json", function(attrs){
    
				depths = [2]

				for (id in attrs) {
					obj = attrs[id]
					depths.forEach(function(d){
						if (d <= obj.id.length) {
							obj["nesting_"+d] = {"name": attrs[obj.id.slice(0, d)].name, "id": obj.id.slice(0, d)}
						}
					})
				}

				inner_html = function(obj) {
					return "This is some test HTML"
				}

				var data = []
				flat_data.data.forEach(function(d, i){
					if (d.hs_id.length == 6) {
						var obj = d
                        obj.id = obj.hs_id  // ID is necessary to generate plot
                        obj.active1 = obj.rca >= 1 ? true : false  // Needed to show pie chart
                        // obj.active2 = obj.rca < 1 ? true : false
                        // obj.distance = null
                        data.push(obj)
                      }
                    })
    
				text_formatting = function(d) {
					return d.charAt(0).toUpperCase() + d.substr(1);
				}

				console.log(data);
				console.log(attrs);
    
				viz
				.type("pie_scatter")
				.text_var("name")
				.id_var("id")
				.attrs(attrs)
				.xaxis_var("distance")
				.yaxis_var("complexity")
				.value_var("distance")
                // .tooltip_info(["distance", "complexity", "val_usd", "rca"])
                // .total_bar({"prefix": "Export Value: $", "suffix": " USD", "format": ",f"})
                .nesting(["nesting_2"]) //,"nesting_4","nesting_6"])
	            .nesting_aggs({"complexity":"mean","distance":"mean","rca":"mean"})
                //.depth("nesting_2")
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