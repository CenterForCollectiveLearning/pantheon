Meteor.publish "histogram_pub", (vizMode, begin, end, L, country, language, category, categoryLevel) ->
  console.log "In histogram publication"
  sub = this
  driver = MongoInternals.defaultRemoteCollectionDriver()

  matchArgs =
    numlangs:
      $gt: L  
    birthyear:
      $gte: begin
      $lte: end
  matchArgs.lang = language if language isnt "all"
  matchArgs[categoryLevel] = category  if category.toLowerCase() isnt "all"

  pipeline = []

  # Given a country, return RCA for each industry
  if vizMode is "country_exports"
    countriesCount = Countries.find().count()

    project =
      _id: 0
      domain: 1
      industry: 1

    # Find global average for the given categorization    
    pipeline = [
      $match: matchArgs
    ,
      $project: project
    ,
      $group:
        _id:
          domain: "$domain"
          industry: "$industry"

        count:
          $sum: 1
    ]

    driver.mongo.db.collection("people").aggregate pipeline, Meteor.bindEnvironment((err, result) ->
      _.each result, (e) ->
        industryGlobalAverages[e._id.industry] = e.count / countriesCount
        root = exports ? this
        root.industryGlobalAverages = industryGlobalAverages
            # console.log e._id.industry, e.count, countriesCount
    , (error) ->
      Meteor._debug "Error doing aggregation: " + error
    )
    console.log "OUTSIDE AGGREGATION", industryGlobalAverages

    matchArgs.countryCode = country if country isnt "all"
    pipeline[0] = $match: matchArgs

    driver.mongo.db.collection("people").aggregate pipeline, Meteor.bindEnvironment((err, result) ->
      _.each result, (e) ->
        # Generate a random disposable id for each aggregate
        # console.log e._id.industry, e.count
        sub.added "histogram", Random.id(),
          domain: e._id.domain
          industry: e._id.industry
          count: e.count
      sub.ready()
    , (error) ->
      Meteor._debug "Error doing aggregation: " + error
    )
