"use strict";

$(document).ready(function () {
	assignEventListeners();
});

function assignEventListeners() {
	$("#play").on("mouseover", function(e) {
		$('#play').attr('src', 'images/play-button-over.jpg');
	});
	
	$("#play").on("mouseout", function(e) {
		$('#play').attr('src', 'images/play-button.jpg');
	});
	
	//lightbox
	$(".youtube").colorbox({iframe:true, innerWidth:700, innerHeight:450});
	
}