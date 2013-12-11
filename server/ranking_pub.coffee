#
# * Static query that pushes the countries ranking table
# *
# * this is the equivalent SQL query:
# * SELECT a.*, b.numwomen, (b.numwomen*1.0/numppl)*100.0 as percent_female
# * FROM
# * (select countryName, countryCode,  count(distinct en_curid) as numppl, count(distinct occupation) numoccs, i50, Hindex
# * from culture3
# * where occupation == "ASTRONAUT"
# * group by countryCode limit 30)
# * AS a
# * left join
# * (select countryCode, count(distinct en_curid) as numwomen
# * from culture3
# * where gender == 'Female' and occupation == "ASTRONAUT"
# * group by countryCode)
# * as b
# * on a.countryCode == b.countryCode;
# *
# 
Meteor.publish "countries_ranking_pub", (begin, end, category, categoryLevel) ->
  sub = this
  collectionName = "countries_ranking"
  criteria = 
    birthyear:
      $gte: begin
      $lte: end
    dataset: "OGC"
  criteria[categoryLevel] = category if category.toLowerCase() isnt "all"
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

  for cc of countries
    country = {}
    country["countryCode"] = cc
    country["countryName"] = countries[cc][0].countryName
    country["continentName"] = countries[cc][0].continentName
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

Meteor.publish "domains_ranking_pub", (begin, end, country, category, categoryLevel) ->
  sub = this
  collectionName = "domains_ranking"
  criteria = birthyear:
    $gte: begin
    $lte: end

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
