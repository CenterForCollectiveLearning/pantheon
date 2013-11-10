# Make sure this is indexed
Meteor.publish "matrix_pub", (begin, end, L, gender) ->
  sub = this
  driver = MongoInternals.defaultRemoteCollectionDriver()

  matchArgs = 
    numlangs:
      $gt: L
    birthyear:
      $gte: begin
      $lte: end

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

  console.log pipeline

  driver.mongo.db.collection("people").aggregate pipeline, Meteor.bindEnvironment((err, result) ->
    _.each result, (e) ->
        
      # Generate a random disposable id for each aggregate
      sub.added "matrix", Random.id(),
        countryCode: e._id.countryCode
        industry: e._id.industry
        count: e.count

    sub.ready()

  , (error) ->
    Meteor._debug "Error doing aggregation: " + error
  )

  # sub = this
  # args =
  #   numlangs:
  #     $gt: L

  #   birthyear:
  #     $gte: begin
  #     $lte: end

  # if gender is "male" or gender is "female"
  #   query = gender.charAt(0).toUpperCase() + gender.slice(1)
  #   args.gender = query
  # console.log args
  # project =
  #   countryCode: 1
  #   industry: 1
  #   gender: 1

  # People.find(args,
  #   fields: project
  # ).forEach (person) ->
  #   sub.added "matrix", Random.id(), person

  # sub.ready()