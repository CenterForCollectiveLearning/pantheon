"use strict";

var LANG, from = -1000,
    to = 1960,
    l = 25,
    playing = false,
    selected_country = "all",
    selected_region = "all",
    selected_domain = "all",
    selected_visualization = "exports",
    countries_filtered, //will contain the filtered copy of countries
    culture, individuals = new Object(),
    individuals_by_sumfin = new Object(),
    inter,
    play_button_delay = 2000; //interval for the play button
    
var color_domain = d3.scale.ordinal()
	.domain(["INSTITUTIONS", "ARTS", "HUMANITIES", "BUSINESS & LAW", "EXPLORATION", "PUBLIC FIGURE", "SCIENCE & TECHNOLOGY", "SPORTS"])
	.range(["#ECD078", "#D95B43", "#43c1d9", "#C02942", "#546c97", "#d278c2", "#53a9f1", "#79BD9A"]);
		
var color_domain_languages = d3.scale.ordinal()
	.domain(["Afro-Asiatic", "Altaic", "Austro-Asiatic", "Austronesian", "Basque", "Caucasian", "Creoles and pidgins", "Dravidian", "Eskimo-Aleut", "Indo-European", "Niger-Kordofanian", "North American Indian", "Sino-Tibetan", "South American Indian", "Tai", "Uralic"])
	.range(["#E0BA9B", "#D95B43", "#43c1d9", "#C02942", "#546c97", "#d278c2", "#53a9f1", "#79BD9A", "#A69E80", "#ECD078", "#D28574", "#E7EDEA", "#CEECEF", "#912D1D", "#DE7838", "#59AB6D"]);
		
var color_domain_countries = d3.scale.ordinal()
	.domain(["Africa", "Asia", "Europe", "North America", "South America", "Oceania"])
	.range(["#E0BA9B", "#D95B43", "#43c1d9", "#C02942", "#546c97", "#d278c2"]);


$(document).ready(function () {
	var opts = {
  lines: 12, // The number of lines to draw
  length: 6, // The length of each line
  width: 3, // The line thickness
  radius: 6, // The radius of the inner circle
  corners: 1, // Corner roundness (0..1)
  rotate: 0, // The rotation offset
  direction: 1, // 1: clockwise, -1: counterclockwise
  color: '#fff', // #rgb or #rrggbb
  speed: 1, // Rounds per second
  trail: 60, // Afterglow percentage
  shadow: false, // Whether to render a shadow
  hwaccel: false, // Whether to use hardware acceleration
  className: 'spinner', // The CSS class to assign to the spinner
  zIndex: 2e9, // The z-index (defaults to 2000000000)
  top: 'auto', // Top position relative to parent in px
  left: 'auto' // Left position relative to parent in px
	};
	var target = document.getElementById('loading');
	var spinner = new Spinner(opts).spin(target);


    //default view
    enableDisableControlsFor("switch_to_exports");

    //other initializations
    $("select, input").uniform();

    //get culture data
    $("#loading").show();

    var query = gimmeQuery();
    var url = "http://culture.media.mit.edu:8080/?query=" + query + "&country=" + selected_country + "&lang=" + selected_region + "&b=" + from + "&e=" + to + "&L=" + l;
    d3.json(url, function (json) {
        culture = json.data;
		console.log(culture);
        getIndividuals();
        addTreemapSvg();

        //$("#loading").hide();
        $("#viz_options").css("opacity", "1");
        $("#viz svg").css("border", "2px solid white");
        $("#ranked_list").css("opacity", "1");
        $.uniform.update();
    });

    //provide lang literals globally
    d3.json("lang/en_US.json", function (data) {
        LANG = data;

        assignEventListeners();
    });

    setTimeout(function () {
        $.uniform.update();
    }, 100);
});

function resetControls() {
    selected_country = "all";
    selected_region = "all";
    selected_domain = "all";

    $("#countries").val("All");
    $("#languages").val("All");
    $("#domain").val("All");
    $.uniform.update("#countries,#languages,#domain");
}

function incrementDate() {
	if(from < 1800) return from+100;
	else if(from < 1900) return from+50;
	else if(from >= 1900) return from+10;
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
		console.log("toggle play");
		$('#play-explore').attr('src', 'images/cyclepause-over.png');
		$('#play-explore').attr('class', 'playing');
		
		$("#go").click();

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
	    addTreemapSvg();
	    
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
	        addTreemapSvg();
		}, play_button_delay);
				
		return false;
	}, function(e) {
		console.log("toggle pause");
		
		clearInterval(inter);
		playing = false;
		
		$('#play-explore').attr('src', 'images/cycle-over.png');
		$('#play-explore').attr('class', 'paused');
	});
	
    $("li a").on("click", function (d) {
    	$("#loading").show();
    	/*$("#viz svg").css("border", "0");
        $("#ranked_list").css("opacity", "0");*/
        
        resetControls();

        var srcE = d.srcElement ? d.srcElement : d.target;
        enableDisableControlsFor($(srcE).attr("id"));
        
        //TODO move this elsewhere later
		if(gimmeQuery() == "domain") {
			$(".legend").fadeIn();
		}
		else {
			$(".legend").fadeOut();
		}
		
        updateQuestion();
        getIndividuals();
        addTreemapSvg();
        
        return false;
    });

    $("#go").on("click", function (d) {
        selected_domain = $("#domain").val();
        selected_country = $("#countries").val();
        selected_region = $("#languages").val();
        l = $("#l").val();
        from = Number($("#from").val());
        to = Number($("#to").val());
        
        $("#loading").show();
    	/*$("#viz svg").css("border", "0");
        $("#ranked_list").css("opacity", "0");*/

        updateQuestion();
		getIndividuals();
        addTreemapSvg();
    });

    $("#viz_pane svg").on("mouseleave", function () {
        $("#tooltip").fadeOut();
    });

    $("#viz_type").on("change", function () {
        changeVisualization($(this).val());
    });

    $("h3 a").on("click", function () {
        return false;
    });

    $('.main_nav a').bind('click', function (event) {
        var anchor = $(this);

        $('html, body').stop().animate({
            scrollTop: $(anchor.attr('href')).offset().top
        }, 900, 'easeInOutExpo');
        
        event.preventDefault();
    });

    $('.secondary_nav a').bind('click', function (event) {
        var anchor = $(this);

        $('html, body').stop().animate({
            scrollTop: $(anchor.attr('href')).offset().top
        }, 900, 'easeInOutExpo');

        event.preventDefault();
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

function getIndividuals() {
	$("#ranked_list .content").empty();

	//what are we grouping individuals by	
	var by_what = "";
	if(gimmeQuery() == "domain")
		by_what = "occupation";
	else if(gimmeQuery() == "language")
		by_what = "";
	else if(gimmeQuery() == "country")
		by_what = "countryName";

	var lang_bit = (selected_region == "all" ) ? "" : "&lang=" + selected_region;

	var gimme_the_domain;
	if(selected_domain.charAt(0) == "-")
		gimme_the_domain = "&occ=" + urlify(selected_domain.substring(1));
	else if(selected_domain.charAt(0) == "+")
		gimme_the_domain = "&ind=" + urlify(selected_domain.substring(1));
	else 
		gimme_the_domain = "&dom=" + urlify(selected_domain);
    
    var url = "http://culture.media.mit.edu:8080/?query=people&country=" + selected_country + gimme_the_domain + lang_bit + "&b=" + from + "&e=" + to + "&L=" + l;
    console.log("getIndividuals", url);
    
    //for ranked list
    d3.json(url+"&limit=10", function (json_data) {
        individuals = json_data.data;
    	populateRanking();
    });
    
    //for treemap cells
    d3.json(url, function (json_data) {
        individuals_by_sumfin = new Object();
        
        if(by_what != "") {
	        $.each(json_data.data, function (key, val) {
    	    	getIndividualsRecursively(key, val, by_what);
    		});
    	}

        //console.log(individuals_by_sumfin);
        
        $("#loading").fadeOut();
    });
}


function getIndividualsRecursively(key, val, by_what) {
    var value = val;

    if (value instanceof Object && value['fb_name'] == undefined) {
        $.each(value, function (key, val) {
            getIndividualsRecursively(key, val, by_what)
        });
    } else if (value instanceof Object && value['fb_name'] != undefined) {
        //if we have a domain filter, keep that in mind before setting anything

        if (individuals_by_sumfin[eval("value." + by_what)] == undefined) {
            individuals_by_sumfin[eval("value." + by_what)] = new Array();
        }

        individuals_by_sumfin[eval("value." + by_what)].push(val);
    }
}



if (!String.prototype.format) {
    String.prototype.format = function () {
        var args = arguments;
        return this.replace(/{(\d+)}/g, function (match, number) {
            return typeof args[number] != 'undefined' ? args[number] : match;
        });
    };
}

function populateRanking() {
    var html_to_show = "";
    setTimeout(function () {
        $.each(individuals, function (i, d) {
            var birthday = (d.birthyear < 0) ? (d.birthyear * -1) + " B.C." : d.birthyear;

            var imgURL = "";

            // //Get individual thumbs for people
            // var imgIdURL = "https://www.googleapis.com/freebase/v1/topic/en/{0}?filter=/common/topic/image&limit=1".format(d.fb_name.replace(/\s+/g, "_").toLowerCase());
            // var imgid = "";
            // //By default show a blank avatar
            // var imgURL = "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcTB0GqCosPU1Gr1kOvS8TMlJXNWt0oHcWoP90-EHHCEYx_xOYetlA";
            // $.getJSON(imgIdURL, function(data) {
            //     if(data.hasOwnProperty('property') && data.property.hasOwnProperty('/common/topic/image')){
            //         imgid = data.property['/common/topic/image'].values[0].id;
            //     }
            //     if(imgid.length > 0){
            //         imgURL = "https://usercontent.googleapis.com/freebase/v1/image{0}".format(imgid);
            //     }
            // });
            // //Note that the img src is commented out now, but is still inserted in the html

            html_to_show += "<div style='padding-bottom:5px'>" + (i + 1) + ". <!--img src='{0}'-->".format(imgURL) + d.fb_name + "<br /><span style='font-size:70%'>" + d.occupation + ", born " + birthday + " (" + d.numlangs + ")</span></div>";

            if (i == 9) return false;
        });

        if (individuals.length == 0) html_to_show = "<i>none for the selected criteria.</i>";

        $("#ranked_list .content").html(html_to_show);
    }, 100);
}

function cell(div) {
    div.style("left", function (d) {
        return d.x + "px";
    }).style("top", function (d) {
        return d.y + "px";
    }).style("width", function (d) {
        return Math.max(0, d.dx - 1) + "px";
    }).style("height", function (d) {
        return Math.max(0, d.dy - 1) + "px";
    });
}

function addTreemapSvg() {
    var width = 725,
        height = 560,
        margin = {
            top: 0,
            right: 0,
            bottom: 0,
            left: 0
        };
    //color = d3.scale.category20();
    var treemap = d3.layout.treemap().padding(0).size([width, height]).value(function (d) {
        return (d.value != undefined) ? d.value : d.numppl;
    });

    var svg = d3.select("#viz svg").attr("width", width).attr("height", height).append("g").attr("transform", "translate(-.5,-.5)");

    var query = gimmeQuery();
    
    var gimme_the_domain;
    if(selected_domain.charAt(0) == "-")
		gimme_the_domain = "&occ=" + urlify(selected_domain.substring(1));
	else if(selected_domain.charAt(0) == "+")
		gimme_the_domain = "&ind=" + urlify(selected_domain.substring(1));
	else 
		gimme_the_domain = "&dom=" + urlify(selected_domain);
    
    var url = "http://culture.media.mit.edu:8080/?query=" + query + gimme_the_domain + "&country=" + selected_country + "&lang=" + selected_region + "&b=" + from + "&e=" + to + "&L=" + l;
    console.log(url);
    d3.json(url, function (json_data) {
    	//$("#viz svg").empty();

        countries_filtered = {
            "name": "-",
            "children": Array()
        };
        countries_filtered.children = json_data.data;

        //console.log(countries_filtered);

        var cell = svg.data([countries_filtered]).selectAll("g").data(treemap.nodes).enter().append("g").attr("class", function (d) {
            if (!d.children || d.children.length == 0) {
                return "cell_" + spacesBeGone(d.parent.name.toLowerCase()) + " leaf cell";
            } else {
                return "parent cell"
            }
        }).attr("transform", function (d) {
            return "translate(" + d.x + "," + d.y + ")";
        });

        cell.append("rect").attr("width", function (d) {
            return d.dx;
        }).attr("height", function (d) {
            return d.dy;
        }).style("cursor", "pointer").style("fill", function (d) {
            if (d.parent && d.parent.parent && d.parent.parent.name != "-") {
            	if(gimmeQuery() == "language")
            		return color_domain_languages(d.parent.parent.name);
            	else if(gimmeQuery() == "country")
	            	return color_domain_countries(d.parent.parent.name);
            	else
	                return color_domain(d.parent.parent.name);
            }
            else if (d.parent && d.parent.parent && d.parent.parent.name == "-") {
            	if(gimmeQuery() == "language")
            		return color_domain_languages(d.parent.name);
            	if(gimmeQuery() == "country")
            		return color_domain_countries(d.parent.name);
            	else
	                return color_domain(d.parent.name);
            }
            else {
                return null;
            }

        });

        d3.selectAll(".leaf").on("mousemove", function (d) {
          //todo, while language tooltips is not implemented
          //change later
          if(individuals_by_sumfin[d.name] != undefined) {	
            var suffix = (individuals_by_sumfin[d.name].length > 1) ? "individuals" : "individual";
            var html_to_show = "<span style='font-weight:700;font-size:110%;letter-spacing:2px'>" + d.name + "</span><br />" + individuals_by_sumfin[d.name].length + " " + suffix + "<div style='width:100%;border-top:1px solid #cccccc;height:5px;margin-top:6px;'></div>";

            var tooltip_individual_threshold = (individuals_by_sumfin[d.name].length < 5) ? individuals_by_sumfin[d.name].length : 5;
            for (var i = 0; i < tooltip_individual_threshold; i++) {
                html_to_show += individuals_by_sumfin[d.name][i].fb_name + "<span style='font-size:70%'>, " + individuals_by_sumfin[d.name][i].location + "</span><br />";
            }

            if (individuals_by_sumfin[d.name].length > tooltip_individual_threshold) {
                html_to_show += "<br /><span style='font-size:80%'>(" + (individuals_by_sumfin[d.name].length - tooltip_individual_threshold) + " more)</span>";
            }

            $("#tooltip").show().html(html_to_show).css("left", (d3.event.pageX + 90) + "px").css("top", (d3.event.pageY - 95) + "px").css("padding", "15px");
          }
          else {
          	var suffix = (d.value > 1) ? "individuals" : "individual";
            var html_to_show = "<span style='font-weight:700;font-size:110%;letter-spacing:2px'>" + d.name + "</span><br />" + d.value + " " + suffix;

            $("#tooltip").show().html(html_to_show).css("left", (d3.event.pageX + 90) + "px").css("top", (d3.event.pageY - 95) + "px").css("padding", "15px");
          }
        });

        cell.append("text").attr("text-anchor", "start").attr('x', '0.2em').attr('y', '0.1em').attr('dy', '1em').attr("font-size", function (d) {
            var size = (d.dx) / 7
            if (d.dx < d.dy) var size = d.dx / 7
            else var size = d.dy / 7
            //if (size < 10) size = 10;
            //console.log(size);
            return size;
        }).style("cursor", "pointer").text(function (d) {
            return d.children ? null : d.name;
        }).each(wordWrap);
        
        
        //$("#loading").hide();
		$("#viz svg").css("border", "2px solid white");
        $("#ranked_list").css("opacity", "1");
    });
}

function wordWrap(d, i) {
    if (this.firstChild == null) return;

    var words = d.name.split(' ');
    var line = new Array();
    var length = 0;
    var text = "";
    var width = d.dx;
    var height = d.dy;
    var word;

    while (words.length) {
        word = words.shift();
        line.push(word);
        if (words.length) this.firstChild.data = line.join(' ') + " " + words[0];
        else this.firstChild.data = line.join(' ');
        length = this.getBBox().width;
        if (length < width && words.length) {;
        } else {
            //console.log(word);
            text = line.join(' ');
			text = toTitleCase(text);
            this.firstChild.data = text;
            if (this.getBBox().width > width) {
                text = d3.select(this).select(function () {
                    return this.lastChild;
                }).text();
                text = text + "...";
                d3.select(this).select(function () {
                    return this.lastChild;
                }).text(text);
                d3.select(this).classed("wordwrapped", true);
                break;
            }

            if (text != '') {
                d3.select(this).append("svg:tspan").attr("x", 0).attr("dx", "0.15em").attr("dy", "0.9em").text(text);
            }

            if (this.getBBox().height > height && words.length) {
                text = d3.select(this).select(function () {
                    return this.lastChild;
                }).text();
                text = text + "...";
                d3.select(this).select(function () {
                    return this.lastChild;
                }).text(text);
                d3.select(this).classed("wordwrapped", true);

                break;
            }

            line = new Array();
        }
    }

    this.firstChild.data = '';
}

function gimmeQuery() {
	if(selected_visualization == "exports" || selected_visualization == "imports")
		return "domain";
	else if(selected_visualization == "exports_to")
		return "country";
	else if(selected_visualization == "imports_from")
		return "language";
	else if(selected_visualization == "exporters_of")
		return "domain";
	else if(selected_visualization == "importers_of")
		return "language";
}

function enableDisableControlsFor(option) {
    $(".top_nav_control").show();
    $(".selected").attr("class", "not_selected");
    $("#" + option).parent().attr("class", "selected");
    $("label").css("opacity", 1);

    switch (option) {
    case "switch_to_exports":
        selected_visualization = "exports";
		
        $("#domain").hide();
        $("#domain_label").css("opacity", 0);
        $("#languages").hide();
        $("#languages_label").css("opacity", 0);
        break;
    case "switch_to_imports":
        selected_visualization = "imports";

        $("#domain").hide();
        $("#domain_label").css("opacity", 0);
        $("#countries").hide();
        $("#countries_label").css("opacity", 0);
        break;
    case "switch_to_exports_to":
        selected_visualization = "exports_to";

		$("#countries").hide();
        $("#countries_label").css("opacity", 0);
        $("#languages").hide();
        $("#languages_label").css("opacity", 0);
        break;
    case "switch_to_imports_from":
        selected_visualization = "imports_from";

        $("#countries").hide();
        $("#countries_label").css("opacity", 0);
        $("#languages").hide();
        $("#languages_label").css("opacity", 0);
        break;
    case "switch_to_exporters_of":
        selected_visualization = "exporters_of";

		$("#domain").hide();
        $("#domain_label").css("opacity", 0);
        break;
    case "switch_to_importers_of":
        selected_visualization = "importers_of";

        $("#languages").hide();
        $("#languages_label").css("opacity", 0);
        break;
    }

    $.uniform.update();
}

function updateQuestion() {
    var html = "";
    var s_countries = (selected_country == "all") ? "the world" : country[selected_country],
        s_domains = (selected_domain == "all") ? "all domains" : decodeURIComponent(selected_domain),
        s_regions = (selected_region == "all") ? "the world" : region[selected_region],
        does_or_do = (selected_country == "all") ? "do" : "does",
        s_or_no_s_c = (selected_country == "all") ? "'" : "'s",
        s_or_no_s_r = (selected_region == "all") ? "'" : "'s",
        speakers_or_no_speakers = (selected_region == "all") ? "" : " speakers";
        
    
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
    	

    switch (selected_visualization) {
    case "exports":
        html = "What does " + s_countries + " export?";
        break;
    case "imports":
        html = (selected_region == "all") ? "What does the world import?" : "What do " + s_regions + " speakers import?";
        break;
    case "exports_to":
        html = "Who exports " + s_domains + "?";
        break;
    case "imports_from":
        html = "Who imports " + s_domains + "?";
        break;
    case "exporters_of":
        html = "What does " + s_countries + " export to " + s_regions + speakers_or_no_speakers + "?";
        break;
    case "importers_of":
        html = "Where does " + s_countries + " export " + s_domains + " to?";
        break;
    }

    $("#question").html(html);
}


function addCommas(nStr) {
    nStr += '';
    var x = nStr.split('.');
    var x1 = x[0];
    var x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
        x1 = x1.replace(rgx, '$1' + ',' + '$2');
    }
    return x1 + x2;
}

function getHumanSize(size) {
    var sizePrefixes = ' kmbtpezyxwvu';
    if (size <= 0) return '0';
    var t2 = Math.min(Math.floor(Math.log(size) / Math.log(1000)), 12);
    return (Math.round(size * 100 / Math.pow(1000, t2)) / 100) +
    //return (Math.round(size * 10 / Math.pow(1000, t2)) / 10) +
    sizePrefixes.charAt(t2).replace(' ', '');
}

function isNumber(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
}

function urlify(str) {
    return str.replace(/ /g, "+").replace(/&/g, "%26");
}

function spacesBeGone(str) {
    return str.replace(/ /g, "_").replace(/&/g, "and");
}

function toTitleCase(str) {
    return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
}