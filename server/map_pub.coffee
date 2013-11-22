Meteor.publish "map_pub", (begin, end, L, category, categoryLevel, dataset) ->
  
  #
  #The query will look something like this:
  # db.people.aggregate([{"$match": {"numlangs": {"$gt": 25}, "birthyear": {"$gte": 0, "$lte":1950}, "domain": 'EXPLORATION'}},
  # {"$group": {"_id": {"countryCode": "$countryCode3", "countryName": "$countryName"}, "count": {"$sum": 1 }}}])
  # 
  sub = this
  driver = MongoInternals.defaultRemoteCollectionDriver()
  
  # TODO modify this query to be more general
  matchArgs =
    numlangs:
      $gt: L

    birthyear:
      $gte: begin
      $lte: end

    dataset: dataset

  matchArgs[categoryLevel] = category  if category.toLowerCase() isnt "all"
  pipeline = []
  pipeline = [
    $match: matchArgs
  ,
    $group:
      _id:
        countryCode: "$countryCode3"
        countryName: "$countryName"

      count:
        $sum: 1
  ]
  driver.mongo.db.collection("people").aggregate pipeline, Meteor.bindEnvironment((err, result) ->
    _.each result, (e) ->
      
      # Generate a random disposable id for each aggregate
      sub.added "worldmap", Random.id(),
        countryCode: e._id.countryCode
        countryName: e._id.countryName
        count: e.count


    sub.ready()
  , (error) ->
    Meteor._debug "Error doing aggregation: " + error
  )
