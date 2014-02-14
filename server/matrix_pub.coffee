# Make sure this is indexed
Meteor.publish "matrix_pub", (begin, end, L, gender, dataset) ->
  sub = this
  driver = MongoInternals.defaultRemoteCollectionDriver()

  matchArgs = 
    birthyear:
      $gte: begin
      $lte: end
    countryCode: {$ne:"UNK"}
    dataset: dataset

  if L[0] is "H" then matchArgs.HPI = {$gt:parseInt(L.slice(1,L.length))} else matchArgs.numlangs = {$gt: parseInt(L)}
  unless gender is "ratio"
    if gender is "male" or gender is "female"
      genderField = gender.charAt(0).toUpperCase() + gender.slice(1)
      matchArgs.gender = genderField
  
    project =
        _id: 0
        countryCode: 1
        industry: 1
  
    pipeline = [
      $match: matchArgs
    ,
      $project: project
    ,
      $group:
        _id:
          countryCode: "$countryCode"
          industry: "$industry"
        count:
          $sum: 1
    ]
  
    driver.mongo.db.collection("people").aggregate pipeline, Meteor.bindEnvironment((err, result) ->
      _.each result, (e) ->
        sub.added "matrix", Random.id(),
          countryCode: e._id.countryCode
          industry: e._id.industry
          count: e.count
      sub.ready()
    , (error) ->
      Meteor._debug "Error doing aggregation: " + error
    )

  # else
  #   results = {}
  #   for gender in ["Male", "Female"]
  #     matchArgs.gender = genderField

  #     project =
  #         _id: 0
  #         countryCode: 1
  #         industry: 1
    
  #     pipeline = [
  #       $match: matchArgs
  #     ,
  #       $project: project
  #     ,
  #       $group:
  #         _id:
  #           countryCode: "$countryCode"
  #           industry: "$industry"
  #         count:
  #           $sum: 1
  #     ]

  #     driver.mongo.db.collection("people").aggregate pipeline, Meteor.bindEnvironment((err, result) ->
  #       _.each result, (e) ->
  #         countryCode = e.countryCode
  #         industry = 
  #       , (error) ->
  #         Meteor._debug "Error doing aggregation: " + error
  #       )