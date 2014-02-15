Meteor.publish "scatterplot_pub", (vizMode, begin, end, L, countryX, countryY, categoryX, categoryY, categoryLevelX, categoryLevelY, dataset) ->
  sub = this
  driver = MongoInternals.defaultRemoteCollectionDriver()
  matchArgs =
    birthyear:
      $gte: begin
      $lte: end
    dataset: dataset
  if L[0] is "H" then matchArgs.HPI = {$gt:parseInt(L.slice(1,L.length))} else matchArgs.numlangs = {$gt: parseInt(L)}
  
  pipeline = []
  if vizMode is "country_vs_country"
    matchArgs.$or = [
      countryCode: countryX
    ,
      countryCode: countryY
    ]

    pipeline = [
      $match: matchArgs
    ,
      $group:
        _id:
          countryCode: "$countryCode"
          domain: "$domain"
          industry: "$industry"
          occupation: "$occupation"

        count:
          $sum: 1
    ]
    console.log JSON.stringify(pipeline)
    driver.mongo.db.collection("people").aggregate pipeline, Meteor.bindEnvironment((err, result) ->
      _.each result, (e) ->
        
        # Generate a random disposable id for each aggregate
        sub.added "scatterplot", Random.id(),
          countryCode: e._id.countryCode
          domain: e._id.domain
          industry: e._id.industry
          occupation: e._id.occupation
          count: e.count


      sub.ready()
    , (error) ->
      Meteor._debug "Error doing aggregation: " + error
    )
  else if vizMode is "domain_vs_domain"
    matchArgs.$or = [{}, {}]
    matchArgs.$or[0][categoryLevelX] = categoryX if categoryX isnt "all"
    matchArgs.$or[1][categoryLevelY] = categoryY if categoryY isnt "all"

    console.log "In scatterplot domain_vs_domain", matchArgs
    pipeline = [
      $match: matchArgs
    ,
      $group:
        _id:
          continent: "$continentName"
          countryCode: "$countryCode"
          domain: "$domain"
          industry: "$industry"
          occupation: "$occupation"

        count:
          $sum: 1
    ]

    console.log JSON.stringify(pipeline)
    driver.mongo.db.collection("people").aggregate pipeline, Meteor.bindEnvironment((err, result) ->
      _.each result, (e) ->
        
        # Generate a random disposable id for each aggregate
        sub.added "scatterplot", Random.id(),
          continent: e._id.continent
          countryCode: e._id.countryCode
          domain: e._id.domain
          industry: e._id.industry
          occupation: e._id.occupation
          count: e.count

      sub.ready()
    , (error) ->
      Meteor._debug "Error doing aggregation: " + error
    )
