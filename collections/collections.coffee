# @ is used to place collections in the global namespace

# Fundamental Collections
@Countries = new Meteor.Collection "countries"
@Domains = new Meteor.Collection "domains"
@People = new Meteor.Collection "people"
@Languages = new Meteor.Collection "languages"
@Imports = new Meteor.Collection "imports"

# Derived Collections
@PeopleTopN = new Meteor.Collection "topNpeople"
@PeopleTop10 = new Meteor.Collection "top10people"
@Treemap = new Meteor.Collection "treemap"
@CountriesRanking = new Meteor.Collection "countries_ranking"
@DomainsRanking = new Meteor.Collection "domains_ranking"
@Matrix = new Meteor.Collection "matrix"
@Scatterplot = new Meteor.Collection "scatterplot"
@WorldMap = new Meteor.Collection "worldmap"
@Tooltips = new Meteor.Collection "tooltipCollection"
@Timeline = new Meteor.Collection "timeline"
@Stacked = new Meteor.Collection "stacked"