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
    # Get global export shares for all industries
    # Can't use aggregation pipeline because of scoping issues
    totalGlobalExports = People.find(matchArgs).count()
    
    data = People.find(matchArgs).fetch()
    industriesData = _.groupBy(data, "industry")
    industryGlobalShares = {}
    for industry, people of industriesData
        industryGlobalShares[industry] = people.length / totalGlobalExports

    # Get country export shares for all industries
    matchArgs.countryCode = country if country isnt "all"
    totalCountryExports = People.find(matchArgs).count()

    # Calculate RCAs for every industry
    pipeline[0] = $match: matchArgs

    project =
      _id: 0
      domain: 1
      industry: 1

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
        count = e.count
        industry = e._id.industry
        countryExportShare = count / totalCountryExports
        globalExportShare = industryGlobalShares[industry]
        rca = countryExportShare / globalExportShare
        if count
          sub.added "histogram", Random.id(),
            domain: e._id.domain
            industry: industry
            count: count
            rca: rca
            countryExportShare: countryExportShare
            globalExportShare: globalExportShare
      sub.ready()
    , (error) ->
      Meteor._debug "Error doing aggregation: " + error
    )

  # Given a country, return RCA for each industry
  else if vizMode is "domain_exports_to"
    # Get industry export shares for all countries
    totalCountryExports = {}
    data = People.find(matchArgs).fetch()
    countriesData = _.groupBy(data, "countryCode")
    for countryCode, people of countriesData
        totalCountryExports[countryCode] = people.length

    # Get global export share for given industry
    totalGlobalExports = People.find(matchArgs).count()
    
    matchArgs[categoryLevel] = category if category.toLowerCase() isnt "all"
    industryGlobalCount = People.find(matchArgs).count() 
    industryGlobalShare = industryGlobalCount / totalGlobalExports

    # Calculate RCAs for every industry
    pipeline[0] = $match: matchArgs

    project =
      _id: 0
      continentName: 1
      countryCode: 1
      countryName: 1

    pipeline = [
      $match: matchArgs
    ,
      $project: project
    ,
      $group:
        _id:
          continentName: "$continentName"
          countryCode: "$countryCode"
          countryName: "$countryName"
        count:
          $sum: 1
    ]

    driver.mongo.db.collection("people").aggregate pipeline, Meteor.bindEnvironment((err, result) ->
      _.each result, (e) ->
        count = e.count
        continentName = e._id.continentName
        countryCode = e._id.countryCode
        countryName = e._id.countryName
        countryExportShare = count / totalCountryExports[countryCode]
        globalExportShare = industryGlobalShare
        rca = countryExportShare / globalExportShare

        if count
          sub.added "histogram", Random.id(),
            continentName: continentName
            countryCode: countryCode
            countryName: countryName         
            count: count
            rca: rca   
            countryExportShare: countryExportShare
            globalExportShare: globalExportShare
      sub.ready()
    , (error) ->
      Meteor._debug "Error doing aggregation: " + error
    )