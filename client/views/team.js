var teamMembers = [
	{
		"name": "César A. Hidalgo"
		,"photo": "images/cesar_hidalgo.png"
		, "description": "Principal Investigator"
		, "role": ["Content", "Data", "Design"]
		, "media": {
			"personal": "http://chidalgo.com/"
			, "twitter": "https://twitter.com/cesifoti"
			, "linkedin": "www.linkedin.com/pub/cesar-a-hidalgo/5/30a/a61"
			, "email": "mailto:hidalgo@mit.edu"
		}
	},
	{
		"name": "Amy Zhao Yu"
		,"photo": "images/amy_yu.png"
		, "description": "Second Year Graduate Student"
		, "role": ["Data", "Content", "Development"]
		, "media": {
			"personal": "http://www.amyyu.net/"
			, "twitter": "https://twitter.com/mangomochi86"
			, "linkedin": "www.linkedin.com/in/amyzhaoyu"
			, "email": "mailto:amy_yu@mit.edu"
		}
	},
	{
		"name": "Kevin Zeng Hu"
		,"photo": "images/kevin_hu.png"
		, "description": "First Year Graduate Student"
		, "role": ["Development", "Design", "Data"]
		, "media": {
			"personal": "http://www.kevinzenghu.com"
			, "twitter": "https://www.twitter.com/kevinzenghu"
			, "linkedin": "http://www.linkedin.com/pub/kevin-hu/58/9a7/404"
			, "email": "mailto:kzh@mit.edu"
		}
	},
	{
		"name": "Ali Almossawi"
		,"photo": "images/ali_almossawi.jpg"
		, "description": "Mozilla Corporation"
		, "role": ["Design"]
		, "media": {
			"personal": "http://almossawi.com/"
			, "twitter": "https://twitter.com/alialmossawi"
			, "linkedin": "www.linkedin.com/in/almossawi/"
			, "email": "almossawi@gmail.com"
		}
	},
	{
		"name": "Shahar Ronen"
		,"photo": "images/shahar_ronen.png"
		, "description": "Graduate Alumnus"
		, "role": ["Data"]
		, "media": {
			"personal": "http://www.shaharronen.com/"
			, "twitter": "https://twitter.com/ShRonen"
			, "linkedin": "http://www.linkedin.com/in/shaharronen"
			, "email": "mailto:sronen@media.mit.edu"
		}
	},
	{
		"name": "Defne Gurel"
		,"photo": "images/defne_gurel.png"
		, "description": "Computer Science Undergraduate"
		, "role": ["Data"]
		, "media": {
			"linkedin": "www.linkedin.com/pub/defne-gurel/63/2a0/ba6"
			, "email": "mailto:defne@mit.edu"
		}
	}
]

Template.team.helpers({
	first_row_teamMembers: function() {
		return teamMembers.slice(0, 3);
	},
	second_row_teamMembers: function() {
		return teamMembers.slice(3, 6);
	}
});

Template.team.events = {
	"mouseenter li.team-member": function(d) {
		var srcE = d.srcElement ? d.srcElement : d.target;
		$(srcE).find('div.info').animate({"opacity": 1.0}, 250);
	},
	"mouseleave li.team-member": function(d) {
		var srcE = d.srcElement ? d.srcElement : d.target;
		$(srcE).find('div.info').animate({"opacity": 0.0}, 250);
	}
}