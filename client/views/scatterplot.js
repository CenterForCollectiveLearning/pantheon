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

	var data = [];
	var aggByOcc = {};
	var flatData = [];
	var attrs = {};

	var vizMode = Session.get('vizMode');
	if (vizMode === 'country_vs_country') {
		var field = 'countryCode';
		var x_code = Session.get('countryX');
		var y_code = Session.get('countryY');
		var x_name = Countries.findOne({countryCode: x_code}).countryName;
		var y_name = Countries.findOne({countryCode: y_code}).countryName;

		var data = Scatterplot.find().fetch();
	} else if (vizMode === 'lang_vs_lang') {
		var field = 'lang';
		var x_code = Session.get('languageX');
		var y_code = Session.get('languageY');
		var x_name = Languages.findOne({lang: x_code}).lang_name;
		var y_name = Languages.findOne({lang: y_code}).lang_name;

		var data = Scatterplot.find().fetch();
	}

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
                , nesting_dom: domDict
            };
            attrs[ind] = {
                id: ind
                , name: ind
                , color: dom_color
                , nesting_dom: domDict
                , nesting_ind: indDict
            };
            attrs[occ] = {
                id: occ
                , name: occ
                , color: dom_color
                , nesting_dom: domDict
                , nesting_ind: indDict
                , nesting_occ: occDict
            };
        });

	/*
	    Flatten data 

	    [{countryCode:'US', 
	    domain: 'INSTITUTIONS', 
	    industry: 'MILITARY', 
	    occupation: 'EXPLORER', 
	    count: 4}]

	    TO
	    
	    {'EXPLORER': {x: 4, y:8}}
	*/
	for (i in data) {
		var datum = data[i]
		var occ = datum.occupation;
		var count = datum.count;
		var code = datum[field];

		var axis = code == x_code ? 'x' : 'y';
		var other_axis = axis == 'x' ? 'y' : 'x';

		if (occ == 'EXPLORER') {
			continue;
    	}

    	if (!aggByOcc.hasOwnProperty(occ)) {
    		aggByOcc[occ] = {};
    		aggByOcc[occ][axis] = count;
    		aggByOcc[occ][other_axis] = 0;
    	} else {
    		aggByOcc[occ][axis] = count;
    	}
	}
	
	for (var occ in aggByOcc) {
		var datum = aggByOcc[occ];
		var x = datum.x;
		var y = datum.y;
		if (occ == 'EXPLORER') {
			continue;
    	}
    	var d = {
			id: occ
			, name: occ
			, active1: true
			, active2: true
			, year: 2002
		}
		d[x_name] = x;
		d[y_name] = y;
		d['total'] = x + y;
		flatData.push(d);          
	}

	text_formatting = function(d) {
		return d.charAt(0).toUpperCase() + d.substr(1);
	}
	inner_html = function(obj) {
		return "This is some test HTML";
	}

	console.log("AGGBYOCC", aggByOcc);
	console.log("FLAT DATA: ", flatData);
	console.log("ATTRS: ", attrs);

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
        .datum(flatData)
        .call(viz)

}