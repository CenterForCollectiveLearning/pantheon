// TODO Use preserve or jQuery UI to prevent wiping-out of nodes?

// TODO How do you get this to run again?
Template.publications.rendered = function() {
    console.log("RENDERED PUBLICATIONS TEMPLATE");
    $.cachedScript('http://www.readrboard.com/static/engage.js').done(function() {
        console.log( "Received Script" );
    });
}