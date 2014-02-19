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
  console.log(criteria)
  country = {}
  data = People.find(criteria).fetch()
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
    country["HCPI"] = countries[cc][0].HCPI
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


    finaldata.push country
  finaldata.forEach (person) ->
    sub.added collectionName, Random.id(), person

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
  finaldata.forEach (person) ->
    sub.added collectionName, Random.id(), person

  sub.ready()
  return
