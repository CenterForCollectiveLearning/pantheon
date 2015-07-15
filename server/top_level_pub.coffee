Meteor.publish "countries_pub", ->
  Countries.find()

Meteor.publish "domains_pub", ->
  Domains.find()

Meteor.publish "people_pub", ->
  People.find()

#
# Publish the top N people for the current query
# Push the ids here as well since people will be in the client side
#
Meteor.publish "peopleTopN", (vizType, vizMode, begin, end, L, country, countryX, countryY, gender, category, categoryX, categoryY, categoryLevel, categoryLevelX, categoryLevelY, N, dataset) ->
  sub = this
  collectionName = "peopleTopN"
  args =
    birthyear:
      $gte: begin
      $lte: end
  
  if country
    country = country.split("+")
  else 
    country = "UNK"
  if country.length > 1 then city = country[0] else city = "all"
  countryCode = country[country.length-1]

  args.dataset = dataset
  args.countryCode = countryCode if countryCode isnt "all" and vizMode is "country_exports" or vizMode is "domain_exports_to_city"
  args.birthcity = city if city isnt "all"

  args[categoryLevel] = category if category.toLowerCase() isnt "all"
  if L[0] is "H" then args.HPI = {$gte:parseInt(L.slice(1,L.length))} else args.numlangs = {$gte: parseInt(L)}
  
  if gender is "male" or gender is "female"
    genderField = gender.charAt(0).toUpperCase() + gender.slice(1)
    args.gender = genderField

  if vizMode is "country_vs_country"
    args.$or = [
      countryCode: countryX
    ,
      countryCode: countryY
    ]
  else if vizMode is "domain_vs_domain"
    or1 = {}
    or2 = {}
    or1[categoryLevelX] = categoryX
    or2[categoryLevelY] = categoryY
    args.$or = [or1, or2]

  if L[0] is "H"
    projection =
      fields:
        _id: 1
        HPI: 1
      sort:
        HPI: -1
  else
    projection =
      fields:
        _id: 1
        numlangs: 1
      sort: 
        numlangs: -1
  projection.limit = N if N isnt "all"
  People.find(args, projection).forEach (person) ->
    sub.added collectionName, person._id, person
  sub.ready()
  return


#
#This is also a static query
#Compare to doing People.find(),
#this just pushes all the people and forgets about them
#and does not incur the overhead of a mongo observe()
#
# Meteor.publish "allpeople", ->
#   sub = this
#   People.find().forEach (person) ->
#     sub.added "people", person._id, person
#   sub.ready()


# No stop needed here

#
#Pass top five people to populate people
#
#Also a static query
#does not send over anything other than the people ids,
#because the whole set of people already exists client side
#

Meteor.publish "tooltipPeople", (vizMode, begin, end, L, country, countryX, countryY, gender, category, categoryX, categoryY, categoryLevel, categoryLevelX, categoryLevelY, dataset, click, selectedcity) ->
  sub = this
  args =
    birthyear:
      $gte: begin
      $lte: end
    dataset: dataset

  if country
    country = country.split("+")
  else 
    country = "UNK"
  if country.length > 1 then city = country[0] else city = "all"
  countryCode = country[country.length-1]

  if L[0] is "H" then args.HPI = {$gte:parseInt(L.slice(1,L.length))} else args.numlangs = {$gte: parseInt(L)}
  # TODO - this is hardcoded fix for matrix to update tooltip with gender - may want to generalize this
  if gender is "male" or gender is "female"
    genderField = gender.charAt(0).toUpperCase() + gender.slice(1)
    if vizMode is "matrix_exports"
      args.gender = genderField

  if vizMode is "country_exports" or vizMode is "matrix_exports" or vizMode is "domain_exports_to"
    args.countryCode = countryCode  if countryCode isnt "all"
    args[categoryLevel] = category  if category.toLowerCase() isnt "all"
    args.birthcity = city if city isnt "all"

  if vizMode is "domain_exports_to_city" #TODO - debug click tooltip
    args.countryCode = countryCode  if countryCode isnt "all"
    args[categoryLevel] = category  if category.toLowerCase() isnt "all"
    args.birthcity = selectedcity if selectedcity isnt "all"

  else if vizMode is "map"
    if dataset is "murray"
      args.countryCode3 = country if country isnt "all"
    else
      args.countryCode = countryCode  if countryCode isnt "all"
      args.birthcity = selectedcity if selectedcity isnt "all"
    args[categoryLevel] = category  if category.toLowerCase() isnt "all"
  else if vizMode is "country_vs_country"
    args[categoryLevel] = category  if category.toLowerCase() isnt "all"
    args.$or = [
      countryCode: countryX
    ,
      countryCode: countryY
    ]
  else if vizMode is "domain_vs_domain"
    args.countryCode = countryCode
    args.$or = [{}, {}]
    args.$or[0][categoryLevelX] = categoryX if categoryX isnt "all"
    args.$or[1][categoryLevelY] = categoryY if categoryY isnt "all"
    
    # argsX = 
    #   birthyear:
    #     $gte: begin
    #     $lte: end
    #   dataset: dataset
    # argsY = 
    #   birthyear:
    #     $gte: begin
    #     $lte: end
    #   dataset: dataset
    # argsX.countryCode = country if country isnt "all"
    # argsY.countryCode = country if country isnt "all"
    # argsX[categoryLevelX] = categoryX if categoryX isnt "all"  
    # argsY[categoryLevelY] = categoryY if categoryY isnt "all" 

  if L[0] is "H"
    projection =
      fields:
        _id: 1
        HPI: 1
      sort:
        HPI: -1
  else
    projection =
      fields:
        _id: 1
        numlangs: 1
      sort:
        numlangs: -1

  projection.limit = 5 if not click

  # Get people
  People.find(args, projection).forEach (person) ->
    sub.added "tooltipCollection", person._id, {}
    
  # Get count
  # Work-around for strange "or" behavior in mongodb (not for minimongo)
  # if argsX and argsY
  #   countX = People.find(argsX, {fields: projection}).count()
  #   countY = People.find(argsY, {fields: projection}).count()
  #   count = countX + countY 
  # else
  count = People.find(args, {fields: projection}).count()

  sub.added "tooltipCollection", "count",
    count: count

  sub.ready()
  return
