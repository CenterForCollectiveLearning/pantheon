#
# * Static query that pushes the treemap structure
# * This needs to run a native mongo query due to aggregates being not supported directly yet
# 
Meteor.publish "treemap_pub", (vizMode, begin, end, L, country, category, categoryLevel, dataset) ->
  sub = this
  driver = MongoInternals.defaultRemoteCollectionDriver()
  matchArgs =
    birthyear:
      $gte: begin
      $lte: end

  matchArgs[categoryLevel] = category if category.toLowerCase() isnt "all"
  matchArgs.dataset = dataset
  if L[0] is "H" then matchArgs.HPI = {$gt:parseInt(L.slice(1,L.length))} else matchArgs.numlangs = {$gt: parseInt(L)}


  pipeline = []
  if vizMode is "country_exports"
    project =
      _id: 0
      domain: 1
      industry: 1
      occupation: 1

    matchArgs.countryCode = country if country isnt "all"
    pipeline = [
      $match: matchArgs
    ,
      $project: project
    ,
      $group:
        _id:
          domain: "$domain"
          industry: "$industry"
          occupation: "$occupation"

        count:
          $sum: 1
    ]
    driver.mongo.db.collection("people").aggregate pipeline, Meteor.bindEnvironment((err, result) ->
      _.each result, (e) ->
        
        # Generate a random disposable id for each aggregate
        sub.added "treemap", Random.id(),
          domain: e._id.domain
          industry: e._id.industry
          occupation: e._id.occupation
          count: e.count


      sub.ready()
    , (error) ->
      Meteor._debug "Error doing aggregation: " + error
    )
  else if vizMode is "country_imports" or vizMode is "bilateral_exporters_of"
    pipeline = [
      $match: matchArgs
    ,
      $group:
        _id:
          domain: "$category"
          industry: "$industry"
          occupation: "$occupation"

        people:
          $addToSet: "$en_curid"
    ,
      $unwind: "$people"
    ,
      $group:
        _id: "$_id"
        count:
          $sum: 1
    ]
    driver.mongo.db.collection("imports").aggregate pipeline, Meteor.bindEnvironment((err, result) ->
      _.each result, (e) ->
        
        # Generate a random disposable id for each aggregate
        sub.added "treemap", Random.id(),
          domain: e._id.domain
          industry: e._id.industry
          occupation: e._id.occupation
          count: e.count

      sub.ready()
    , (error) ->
      Meteor._debug "Error doing aggregation: " + error
    )
  else if vizMode is "domain_exports_to"
    project =
      _id: 0
      continent: 1
      countryCode: 1
      countryName: 1

    console.log matchArgs
    pipeline = [
      $match: matchArgs
    ,
      $project: project
    ,
      $group:
        _id:
          continent: "$continentName"
          countryCode: "$countryCode"
          countryName: "$countryName"

        count:
          $sum: 1
    ]
    driver.mongo.db.collection("people").aggregate pipeline, Meteor.bindEnvironment((err, result) ->
      _.each result, (e) ->
        
        # Generate a random disposable id for each aggregate
        sub.added "treemap", Random.id(),
          continent: e._id.continent
          countryCode: e._id.countryCode
          countryName: e._id.countryName
          count: e.count
      sub.ready()
    , (error) ->
      Meteor._debug "Error doing aggregation: " + error
    )
  else if vizMode is "domain_imports_from" or vizMode is "bilateral_importers_of"
    pipeline = [
      $match: matchArgs
    ,
      $group:
        _id:
          lang_family: "$lang_family"
          lang: "$lang"
          lang_name: "$lang_name"

        people:
          $addToSet: "$en_curid"
    ,
      $unwind: "$people"
    ,
      $group:
        _id: "$_id"
        count:
          $sum: 1
    ]
    driver.mongo.db.collection("imports").aggregate pipeline, Meteor.bindEnvironment((err, result) ->
      _.each result, (e) ->
        
        # Generate a random disposable id for each aggregate
        sub.added "treemap", Random.id(),
          lang_family: e._id.lang_family
          lang: e._id.lang
          lang_name: e._id.lang_name
          count: e.count


      sub.ready()
    , (error) ->
      Meteor._debug "Error doing aggregation: " + error
    )
