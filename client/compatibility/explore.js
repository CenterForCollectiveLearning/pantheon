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


    // TODO these in meteor

    //default view
    // enableDisableControlsFor("switch_to_exports");

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