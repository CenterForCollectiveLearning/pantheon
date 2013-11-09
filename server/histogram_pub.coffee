Meteor.publish "histogram_pub", (vizMode, begin, end, L, country, language, category, categoryLevel) ->
  console.log "In histogram publication"
  sub = this
  allAverages = {}
  driver = MongoInternals.defaultRemoteCollectionDriver()

  matchArgs =
    numlangs:
      $gt: L  
    birthyear:
      $gte: begin
      $lte: end
  # matchArgs.lang = language if language isnt "all"
  # matchArgs[categoryLevel] = category  if category.toLowerCase() isnt "all"

  pipeline = []

  # Given a country, return RCA for each industry
  if vizMode is "country_exports"
    countriesCount = Countries.find().count()

    # Get global averages for industries
    # Can't use aggregation pipeline because of scoping issues
    data = People.find(matchArgs).fetch()
    industriesData = _.groupBy(data, "industry")
    industryGlobalAverages = {}
    for industry, people of industriesData
        industryGlobalAverages[industry] = people.length / countriesCount

    # Calculate RCAs for every industry
    project =
      _id: 0
      domain: 1
      industry: 1

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

        count:
          $sum: 1
    ]
    
    pipeline[0] = $match: matchArgs

    driver.mongo.db.collection("people").aggregate pipeline, Meteor.bindEnvironment((err, result) ->
      _.each result, (e) ->
        count = e.count
        industry = e._id.industry
        sub.added "histogram", Random.id(),
          domain: e._id.domain
          industry: industry
          count: count
          rca: count / industryGlobalAverages[industry]
          globalAverage: industryGlobalAverages[industry]
      sub.ready()
    , (error) ->
      Meteor._debug "Error doing aggregation: " + error
    )
