# Indexes
# Index Usage (???): db.runCommand( { serverStatus: 0, repl: 0, indexCounters: 1 } ).indexCounters

# Heuristics: If _id not included in index, drop in projection

# 
# TREEMAPS
# 

# Country Exports (birthyear, numlangs, [category], [country])
# Checked: db.people.find({numlangs: { '$gt': 25 }, birthyear: { '$gte': -1000, '$lte': 1950 }, countryCode: 'CN'}, {_id: 0, domain: 1, industry: 1, occupation: 1}).explain()
People._ensureIndex
  numlangs: 1
  birthyear: 1
  countryCode: 1
  domain: 1
  industry: 1
  occupation: 1

# Domain Exports
# Checked: db.people.find({ numlangs: { '$gt': 25 }, birthyear: { '$gte': -1000, '$lte': 1950 }, domain: 'ARTS' }, {_id: 0, countryCode: 1, countryName: 1, continent: 1}).explain()
People._ensureIndex
  numlangs: 1
  birthyear: 1
  domain: 1
  countryCode: 1
  countryName: 1
  continent: 1

People._ensureIndex
  numlangs: 1
  birthyear: 1
  industry: 1
  countryCode: 1
  countryName: 1
  continent: 1

People._ensureIndex
  numlangs: 1
  birthyear: 1
  occupation: 1
  countryCode: 1
  countryName: 1
  continent: 1


# 
# MATRICES
# 

# Matrix (birthyear, numlangs, gender)
# Index needed here to iterate through people
# Checked: db.people.find({ numlangs: { '$gt': 25 }, birthyear: { '$gte': -1000, '$lte': 1950 }, gender: 'Female' }, {_id: 0, countryCode: 1, industry: 1}).explain()
People._ensureIndex
  numlangs: 1
  birthyear: 1
  gender: 1
  countryCode: 1
  industry: 1
  _id: 1

# 
# TOOLTIPS
# 

# Country Exports (input: country, occupation)
@domain_countryCode =
  _id: 1
  birthyear: 1
  numlangs: 1
  domain: 1
  countryCode: 1

@industry_countryCode =
  _id: 1
  birthyear: 1
  numlangs: 1
  industry: 1
  countryCode: 1

@occupation_countryCode =
  _id: 1
  birthyear: 1
  numlangs: 1
  occupation: 1
  countryCode: 1

People._ensureIndex domain_countryCode
People._ensureIndex industry_countryCode
People._ensureIndex occupation_countryCode

# Domain Exporters (input: country, occupation)
# People._ensureIndex({ occupation: 1, countryCode: 1, birthyear: 1, numlangs: 1});

#
# * Need to have a prefix of all the lookups we are going to do
#  * in at least one of the indices below
# 

# Imports._ensureIndex({ birthyear: 1, countryCode: 1,  occupation: 1} );
# Imports._ensureIndex({ continentName:1, countryCode: 1, occupation: 1, birthyear: 1} );
# Imports._ensureIndex({ lang_family: 1, lang: 1, occupation: 1, birthyear: 1} );
# Imports._ensureIndex({ category: 1, industry: 1, occupation: 1, birthyear: 1} );
# Imports._ensureIndex({ industry: 1} );
# Imports._ensureIndex({ occupation: 1} );
# Imports._ensureIndex({ countryCode: 1, numlangs: 1, birthyear: 1}, {background: true});
# Imports._ensureIndex({birthyear: 1, numlangs: 1});