#
# * Static query that pushes the data for the stacked area charts
# * This needs to run a native mongo query due to aggregates being not supported directly yet
# 
Meteor.publish "stacked_pub", (vizMode, begin, end, L, country, language, category, categoryLevel) ->
  sub = this
  driver = MongoInternals.defaultRemoteCollectionDriver()
  matchArgs =
    numlangs:
      $gt: L

    birthyear:
      $gte: begin
      $lte: end

  matchArgs[categoryLevel] = category  if category.toLowerCase() isnt "all"
  pipeline = []

  if vizMode is "country_exports"
    project =
      _id: 0
      occupation: 1
      year: 1

    matchArgs.countryCode = country  if country isnt "all"
    pipeline = [
      $match: matchArgs
    ,
      $group:
        _id:
          occupation: "$occupation"
          year: "$birthyear"

        count:
          $sum: 1
    ]
    console.log "COUNTRY_EXPORTS", pipeline
    driver.mongo.db.collection("people").aggregate pipeline, Meteor.bindEnvironment((err, result) ->
      _.each result, (e) ->
        # Generate a random disposable id for each aggregate
        sub.added "stacked", Random.id(),
          occupation: e._id.occupation
          year: e._id.year
          count: e.count

      sub.ready()
    , (error) ->
      Meteor._debug "Error doing aggregation: " + error
    )
