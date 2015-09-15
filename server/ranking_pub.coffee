#
# * Static query that pushes the countries ranking table
# *
# 
Meteor.publish "countries_ranking_pub", (begin, end, category, categoryLevel, L) ->
  sub = this
  collectionName = "countries_ranking"
  criteria = 
    countryCode: 
      $ne: "UNK"
    birthyear:
      $gte: begin
      $lte: end
    dataset: "OGC"
  criteria[categoryLevel] = category if category.toLowerCase() isnt "all"
  if L[0] is "H" then criteria.HPI = {$gt:parseInt(L.slice(1,L.length))} else criteria.numlangs = {$gt: parseInt(L)}

  projection =
    countryName: 1
    continentName: 1
    gender: 1
    numlangs: 1
    HPI:1
    _id: 0
  country = {}
  data = People.find(criteria, projection).fetch()
  countries = _.groupBy(data, "countryCode")
  finaldata = []
  hdata = {}

  for cc of countries #build an object with all of the H-index data
    countrylangs = _.groupBy(countries[cc], "numlangs")
    nums = _.sortBy(_.keys(countrylangs), (num) -> parseInt(num)).reverse()
    sumppl = 0
    for n in nums
      sumppl += parseInt(countrylangs[n].length)
      numlangs = parseInt(n)
      if sumppl >= numlangs
        hdata[cc] = numlangs
        break
      else
        hdata[cc] = sumppl

  for cc of countries
    country = {}
    country["countryCode"] = cc
    country["countryName"] = countries[cc][0].countryName
    country["continentName"] = countries[cc][0].continentName
    # country["HCPI"] = countries[cc][0].HCPI
    # console.log(country["countryName"], country["HCPI"])
    country["HCPI"] = _.reduce(_.pluck(countries[cc], 'HPI'), 
      (memo, num) -> 
        memo + num
      , 0)
    country["numppl"] = countries[cc].length
    females = _.countBy(countries[cc], (p) ->
      (if p.gender is "Female" then "Female" else "Male")
    ).Female
    fifties = _.countBy(countries[cc], (p) ->
      (if p.numlangs >= 50 then "fifty" else "not")
    ).fifty
    country["numwomen"] = (if females then females else 0)
    country["diversity"] = Object.keys(_.groupBy(countries[cc], "occupation")).length
    country["percentwomen"] = (country["numwomen"] / country["numppl"] * 100.0).toFixed(2)
    country["i50"] = (if fifties then fifties else 0)
    country["Hindex"] = hdata[cc]
    if country['countryName'] != null and country['countryName'] != "" then finaldata.push country

  finaldata.forEach (country) ->
    sub.added collectionName, Random.id(), country

  sub.ready()
  return

Meteor.publish "domains_ranking_pub", (begin, end, country, category, categoryLevel, L) ->
  sub = this
  collectionName = "domains_ranking"
  criteria = 
    birthyear:
      $gte: begin
      $lte: end
  projection = 
    occupation : 1
    industry : 1
    domain : 1
    countryCode : 1
    gender : 1
  if L[0] is "H" then criteria.HPI = {$gt:parseInt(L.slice(1,L.length))} else criteria.numlangs = {$gt: parseInt(L)}
  criteria.countryCode = country  if country isnt "all"
  criteria[categoryLevel] = category  if category.toLowerCase() isnt "all"
  domain = {}
  data = People.find(criteria)
  domains = _.groupBy(data.fetch(), "occupation")
  finaldata = []
  for d of domains
    domain = {}
    domain["occupation"] = d
    domain["industry"] = domains[d][0].industry
    domain["domain"] = domains[d][0].domain
    domain["ubiquity"] = Object.keys(_.groupBy(domains[d], "countryCode")).length
    domain["numppl"] = domains[d].length
    females = _.countBy(domains[d], (p) ->
      (if p.gender is "Female" then "Female" else "Male")
    ).Female
    domain["numwomen"] = (if females then females else 0)
    domain["percentwomen"] = (domain["numwomen"] / domain["numppl"] * 100.0).toFixed(2)
    finaldata.push domain
  finaldata.forEach (domain) ->
    sub.added collectionName, Random.id(), domain

  sub.ready()
  return

#
# * Static query that pushes the cities ranking table
# *
# 
Meteor.publish "cities_ranking_pub", (begin, end, country, category, categoryLevel, L) ->
  sub = this
  collectionName = "cities_ranking"
  criteria = 
    birthcity:
      $nin: [null, "", "Other", "Unknown"]
    birthyear:
      $gte: begin
      $lte: end
    dataset: "OGC"
  criteria[categoryLevel] = category if category.toLowerCase() isnt "all"
  criteria.countryCode = country  if country isnt "all"
  if L[0] is "H" then criteria.HPI = {$gt:parseInt(L.slice(1,L.length))} else criteria.numlangs = {$gt: parseInt(L)}

  projection =
    birthcity: 1
    birthstate: 1
    countryName: 1
    continentName: 1
    gender: 1
    numlangs: 1
    HPI:1
    _id: 0
  country = {}
  data = People.find(criteria, projection).fetch()
  cities = _.groupBy(data, "birthcity") # TODO: group by country then city
  finaldata = []
  hdata = {}

  for cc of cities #build an object with all of the H-index data
    citylangs = _.groupBy(cities[cc], "numlangs")
    nums = _.sortBy(_.keys(citylangs), (num) -> parseInt(num)).reverse()
    sumppl = 0
    for n in nums
      sumppl += parseInt(citylangs[n].length)
      numlangs = parseInt(n)
      if sumppl >= numlangs
        hdata[cc] = numlangs
        break
      else
        hdata[cc] = sumppl

  for cc of cities
    city = {}
    city["birthcity"] = cc
    city["birthstate"] = cities[cc][0].birthstate
    city["countryCode"] = cities[cc][0].countryCode
    city["countryName"] = cities[cc][0].countryName
    city["continentName"] = cities[cc][0].continentName
    city["HCPI"] = _.reduce(_.pluck(cities[cc], 'HPI'), 
      (memo, num) -> 
        memo + num
      , 0)
    city["numppl"] = cities[cc].length
    females = _.countBy(cities[cc], (p) ->
      (if p.gender is "Female" then "Female" else "Male")
    ).Female
    fifties = _.countBy(cities[cc], (p) ->
      (if p.numlangs >= 50 then "fifty" else "not")
    ).fifty
    city["numwomen"] = (if females then females else 0)
    city["diversity"] = Object.keys(_.groupBy(cities[cc], "occupation")).length
    city["percentwomen"] = (city["numwomen"] / city["numppl"] * 100.0).toFixed(2)
    city["i50"] = (if fifties then fifties else 0)
    city["Hindex"] = hdata[cc]
    if city['countryName'] != null and city['countryName'] != "" then finaldata.push city

  finaldata.forEach (city) ->
    sub.added collectionName, Random.id(), city

  sub.ready()
  return
