# Indexes

# Heuristics: For aggregation, need to index grouped-on fields not only matched fields
# Explaining Aggregations http://stackoverflow.com/questions/19591405/index-optimization-for-mongodb-aggregation-framework

#
# TREEMAPS
#

# Country exports
# TRUE: db.people.runCommand("aggregate", {pipeline: [{"$match":{"birthyear":{"$gte":-3000,"$lte":2000},"dataset":"OGC","HPI":{"$gt":0},"countryCode":"NZ"}},{"$project":{"_id":0,"domain":1,"industry":1,"occupation":1}},{"$group":{"_id":{"domain":"$domain","industry":"$industry","occupation":"$occupation"},"count":{"$sum":1}}}], explain: true}).serverPipeline[0].cursor.indexOnly
@countryExportsIndex_hpi = {dataset: 1, birthyear: 1, countryCode: 1, domain: 1, industry: 1, occupation: 1, HPI: 1, _id: 1}
@countryExportsIndex_numlangs = {dataset: 1, birthyear: 1, countryCode: 1, domain: 1, industry: 1, occupation: 1, numlangs: 1, _id: 1}
People._ensureIndex(countryExportsIndex_hpi)
People._ensureIndex(countryExportsIndex_numlangs)

# Domain exporters
# FALSE: db.people.runCommand("aggregate", {pipeline: [{"$match":{"birthyear":{"$gte":-3000,"$lte":2000},"industry":"MATH","dataset":"OGC","HPI":{"$gt":0}}},{"$project":{"_id":0,"continent":1,"countryCode":1,"countryName":1}},{"$group":{"_id":{"continent":"$continentName","countryCode":"$countryCode","countryName":"$countryName"},"count":{"$sum":1}}}], explain: true}).serverPipeline[0].cursor.indexOnly
@domainExportersIndex_domain_hpi = {dataset: 1, birthyear: 1, continent: 1, countryName: 1, countryCode: 1, domain: 1, HPI: 1}
@domainExportersIndex_industry_hpi = {dataset: 1, birthyear: 1, continent: 1, countryName: 1, countryCode: 1, industry: 1, HPI: 1}
@domainExportersIndex_occupation_hpi = {dataset: 1, birthyear: 1, continent: 1, countryName: 1, countryCode: 1, occupation: 1, HPI: 1}
@domainExportersIndex_domain_numlangs = {dataset: 1, birthyear: 1, continent: 1, countryName: 1, countryCode: 1, domain: 1, numlangs: 1}
@domainExportersIndex_industry_numlangs = {dataset: 1, birthyear: 1, continent: 1, countryName: 1, countryCode: 1, industry: 1, numlangs: 1}
@domainExportersIndex_occupation_numlangs = {dataset: 1, birthyear: 1, continent: 1, countryName: 1, countryCode: 1, occupation: 1, numlangs: 1}
People._ensureIndex(domainExportersIndex_domain_hpi)
People._ensureIndex(domainExportersIndex_industry_hpi)
People._ensureIndex(domainExportersIndex_occupation_hpi)
People._ensureIndex(domainExportersIndex_domain_numlangs)
People._ensureIndex(domainExportersIndex_industry_numlangs)
People._ensureIndex(domainExportersIndex_occupation_numlangs)

# 
# MATRICES
#

# FALSE: db.people.runCommand("aggregate", {pipeline: [{"$match":{"birthyear":{"$gte":-3000,"$lte":2000},"countryCode":{"$ne":"UNK"},"dataset":"OGC","HPI":{"$gt":0}}},{"$project":{"_id":0,"countryCode":1,"industry":1}},{"$group":{"_id":{"countryCode":"$countryCode","industry":"$industry"},"count":{"$sum":1}}}], explain: true}).serverPipeline[0].cursor.indexOnly
@matrix_hpi = {dataset: 1, birthyear: 1, countryCode: 1, industry: 1, HPI: 1, gender: 1, _id: 1}
@matrix_numlangs = {dataset: 1, birthyear: 1, countryCode: 1, industry: 1, numlangs: 1, gender: 1, _id: 1}
People._ensureIndex(matrix_hpi)
People._ensureIndex(matrix_numlangs)

#
# SCATTERPLOTS
#
# Country vs. Country
# TRUE: db.people.runCommand("aggregate", {pipeline: [{"$match":{"birthyear":{"$gte":-3000,"$lte":2000},"dataset":"OGC","HPI":{"$gt":0},"$or":[{"countryCode":"SE"},{"countryCode":"SY"}]}},{"$group":{"_id":{"countryCode":"$countryCode","domain":"$domain","industry":"$industry","occupation":"$occupation"},"count":{"$sum":1}}}], explain: true}).serverPipeline[0].cursor.clauses[0].indexOnly
# Handled by countryExportsIndex_hpi
# TRUE: db.people.runCommand("aggregate", {pipeline: [{"$match":{"birthyear":{"$gte":-3000,"$lte":2000},"dataset":"OGC","numlangs":{"$gt":25},"$or":[{"countryCode":"SE"},{"countryCode":"SY"}]}},{"$group":{"_id":{"countryCode":"$countryCode","domain":"$domain","industry":"$industry","occupation":"$occupation"},"count":{"$sum":1}}}], explain: true}).serverPipeline[0].cursor.clauses[0].indexOnly
# Handled by countryExportsIndex_numlangs

# Category vs. Category
# FALSE: db.people.runCommand("aggregate", {pipeline: [{"$match":{"birthyear":{"$gte":-3000,"$lte":2000},"dataset":"OGC","HPI":{"$gt":0},"$or":[{"occupation":"CHEMIST"},{"industry":"FINE ARTS"}]}},{"$group":{"_id":{"continent":"$continentName","countryCode":"$countryCode","domain":"$domain","industry":"$industry","occupation":"$occupation"},"count":{"$sum":1}}}], explain: true}).serverPipeline[0].cursor.clauses[0].indexOnly
@categoryVcategoryIndex_hpi = {dataset: 1, birthyear: 1, countryCode: 1, continentName: 1, occupation: 1, domain: 1, industry: 1, HPI: 1, _id: 1}
@categoryVcategoryIndex_numlangs = {dataset: 1, birthyear: 1, countryCode: 1, continentName: 1, domain: 1, industry: 1, occupation: 1, numlangs: 1, _id: 1}
People._ensureIndex(categoryVcategoryIndex_hpi)
People._ensureIndex(categoryVcategoryIndex_numlangs)

# 
# MAPS
# 
# TRUE: db.people.runCommand("aggregate", {pipeline: [ { '$match': 
#      { "birthyear":{"$gte":-3000,"$lte":2000}, 
#        dataset: 'OGC',
#        occupation: 'CHEMIST',
#        HPI: {"$gt":0} } },
#   { '$group': { _id: {countryCode: "$countryCode3",countryName: "$countryName"}, count: {$sum: 1} } } ], explain: true}).serverPipeline[0].cursor.indexOnly

@maps_hpi = {dataset: 1, birthyear: 1, occupation: 1, industry: 1, domain:1, HPI: 1, countryCode3:1, countryName:1, _id: 1}
@maps_numlangs = {dataset: 1, birthyear: 1, occupation: 1, industry: 1, domain:1, numlangs: 1, countryCode3:1, countryName:1, _id: 1}
People._ensureIndex(maps_hpi)
People._ensureIndex(maps_numlangs)

# 
# TOOLTIPS
# 

# Country Exports (input: country, category)
# TRUE: db.people.find({"birthyear":{"$gte":-3000,"$lte":2000},"dataset":"OGC","HPI":{"$gte":0},"countryCode":"DE","occupation":"SOCCER PLAYER"}, {"_id":1,"HPI":1}, {"sort":{"HPI":-1},"limit":5}).explain().indexOnly
# Handled by countryExportsIndex_hpi

# Domain Exports (input: same as above)
# TRUE: db.people.find({"birthyear":{"$gte":-3000,"$lte":2000},"dataset":"OGC","HPI":{"$gte":0},"countryCode":"IT","industry":"MEDICINE"}, {"_id":1,"HPI":1}, {"sort":{"HPI":-1},"limit":5}).explain().indexOnly 
# Handled by countryExportsIndex_hpi

# Matrix (input: country, category, gender)
# FALSE: db.people.find({"birthyear":{"$gte":-3000,"$lte":2000},"dataset":"OGC","HPI":{"$gte":0},"gender":"Female","countryCode":"US","industry":"FILM AND THEATRE"}, {"_id":1, "HPI":1}, {"sort":{"HPI":-1},"limit":5}).explain().indexOnly
# Handled by matrix_hpi


# 
# RANKINGS
# 
# Country Rankings
# FALSE: db.people.find({"countryCode":{"$ne":"UNK"},"birthyear":{"$gte":-4000,"$lte":2010},"dataset":"OGC","HPI":{"$gt":0}, "domain": "ARTS"}, {countryName: 1, continentName: 1, HCPI: 1, length: 1, _id: 0}).explain().indexOnly
People._ensureIndex({dataset: 1, birthyear: 1, countryCode: 1, HPI: 1, countryName: 1, continentName: 1, countryName: 1, occupation: 1, HCPI: 1, gender: 1, numlangs: 1})

# People
# handled on the client (in ClientPeople)

# Domains
# TRUE: db.people.find({ birthyear: { '$gte': -4000, '$lte': 2010 }, HPI: { '$gt': 0 }, countryCode: 'BO', domain: 'ARTS' },  { occupation: 1, industry: 1, domain: 1, countryCode: 1, gender: 1 }).explain().indexOnly
@domainRanking_HPI = {birthyear: 1, countryCode: 1, domain:1, industry: 1, occupation:1, gender: 1, HPI:1, _id: 1}
People._ensureIndex(domainRanking_HPI)
@domainRanking_numlangs = {birthyear: 1, countryCode: 1, domain:1, industry: 1, occupation:1, gender: 1, numlangs:1, _id: 1}
People._ensureIndex(domainRanking_numlangs)



# 
# PEOPLE
# 

## TODO Pass a hint!

# TRUE: db.people.find({name: "Richard Wagner", dataset: "OGC"}, {HPI: 1, occupation: 1}).explain().indexOnly
@people_individual = {name: 1, dataset: 1, occupation: 1, birthyear: 1, countryName: 1}

# FALSE: db.people.find({"HPI":{"$gt":30.91190978},"dataset":"OGC","occupation":"POLITICIAN"}, {"_id": 0, "name": 1, "HPI": 1}).explain().indexOnly
@people_occupation = {HPI: 1, dataset: 1, occupation: 1, name: 1}

# FALSE: db.people.find({"HPI":{"$gt":32.84608581},"dataset":"OGC","countryName":"Germany"}, {"_id": 0, "name": 1, "HPI": 1}).explain().indexOnly
@people_countryName = {HPI: 1, dataset: 1, countryName: 1, name: 1}

# FALSE: db.people.find({"HPI":{"$gt":32.84608581},"dataset":"OGC","birthyear":1813}, {"_id": 0, "name": 1, "HPI": 1}).explain().indexOnly
@people_birthyear = {HPI: 1, dataset: 1, birthyear: 1, name: 1}
