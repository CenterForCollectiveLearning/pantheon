getCountryExportArgs = (begin, end, L, country, category, categoryLevel) ->
  args =
    birthyear:
      $gt: begin
      $lte: end

    numlangs:
      $gt: L

  args.countryCode = country  if country isnt "all"
  args[categoryLevel] = category  if category isnt `undefined` and occ isnt "all"
  args
Meteor.publish "countries_pub", ->
  Countries.find()

Meteor.publish "domains_pub", ->
  Domains.find()

Meteor.publish "languages_pub", ->
  Languages.find()


#
#    Publish the top 10 people for the current query
#    This is a static query since the query doesn't ever change for some given parameters
#    Push the ids here as well since people will be in the client side
# 
Meteor.publish "peopletop10", (begin, end, L, country, category, categoryLevel) ->
  sub = this
  collectionName = "top10people"
  args = getCountryExportArgs(begin, end, L, country)
  args[categoryLevel] = category  if category.toLowerCase() isnt "all"
  # Include numlangs in order to sort
  People.find(args,
    fields:
      _id: 1
      numlangs: 1

    limit: 10
    sort:
      numlangs: -1
  ).forEach (person) ->
    sub.added collectionName, person._id, person

  sub.ready()
  return


#
# Publish the top N people for the current query
# This is a static query since the query doesn't ever change for some given parameters
# Push the ids here as well since people will be in the client side
# 
Meteor.publish "peopletopN", (begin, end, L, country, category, categoryLevel, N) ->
  sub = this
  collectionName = "topNpeople"
  criteria = getCountryExportArgs(begin, end, L, country)
  projection = {}
  projection.limit = N  if N isnt "all"
  criteria[categoryLevel] = category  if category.toLowerCase() isnt "all"
  console.log "CRITERIA: "
  console.log criteria
  console.log "PROJECTION: "
  console.log projection
  People.find(criteria, projection).forEach (person) ->
    sub.added collectionName, person._id, person

  sub.ready()
  
  #
  #    People.find(criteria, projection).forEach(function(person){
  #        table += "<tr class='"+ person.domain + "'>";
  #        table += "<td>1</td>";
  #        table += "<td>" + person.name + "</td>";
  #        table += "<td>" + person.countryName + "</td>";
  #        table += "<td>" + person.birthyear + "</td>";
  #        table += "<td>" + person.gender + "</td>";
  #        table += "<td>" + person.occupation + "</td>";
  #        table += "<td>" + person.numlangs + "</td>";
  #        table += "</tr>";
  #    });
  #
  #    console.log(table);
  #
  #    sub.added(collectionName, "table", {table: table});
  sub.ready()
  return


#
#    Publish five people (+/- two) given a rank and either a country, domain, or birthyear range.
#    TODO: How do you do this correctly?X1
# 
Meteor.publish "fivepeoplebyrank", (begin, end, L, country, domain) ->
  sub = this
  collectionName = "fivepeople"
  args = getCountryExportArgs(begin, end, L, country)
  sub.ready()
  return


#
#This is also a static query
#Compare to doing People.find(),
#this just pushes all the people and forgets about them
#and does not incur the overhead of a mongo observe()
#
Meteor.publish "allpeople", ->
  sub = this
  People.find().forEach (person) ->
    sub.added "people", person._id, person

  sub.ready()


# No stop needed here

#
#Pass top five people to populate people
#
#Also a static query
#does not send over anything other than the people ids,
#because the whole set of people already exists client side
#

# TODO Combine with TOP N query?
Meteor.publish "tooltipPeople", (vizMode, begin, end, L, country, countryX, countryY, gender, category, categoryX, categoryY, categoryLevel) ->
  sub = this
  args =
    numlangs:
      $gt: L

    birthyear:
      $gte: begin
      $lte: end

  if vizMode is "country_exports" or vizMode is "matrix_exports" or vizMode is "domain_exports_to" or vizMode is "map"
    args.countryCode = country  if country isnt "all"
    args[categoryLevel] = category  if category.toLowerCase() isnt "all"
  else if vizMode is "country_vs_country"
    args[categoryLevel] = category  if category.toLowerCase() isnt "all"
    args.$or = [
      countryCode: countryX
    ,
      countryCode: countryY
    ]
  else if vizMode is "domain_vs_domain"
    args.countryCode = country  if country isnt "all"
    or1 = {}
    or2 = {}
    or1[categoryLevel] = categoryX
    or2[categoryLevel] = categoryY
    args.$or = [or1, or2]
  projection = _id: 1
  limit = 5
  sort = numlangs: -1
  
  # Get people
  People.find(args,
    fields: projection
    limit: limit
    sort: sort
    hint: occupation_countryCode
  ).forEach (person) ->
    sub.added "tooltipCollection", person._id, {}

  
  # Get count
  count = People.find(args,
    fields: projection
    hint: occupation_countryCode
  ).count()
  sub.added "tooltipCollection", "count",
    count: count

  sub.ready()
  return
