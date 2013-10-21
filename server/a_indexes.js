// Indexes
// db.runCommand( { serverStatus: 0, repl: 0, indexCounters: 1 } ).indexCounters

/* 
 * TREEMAPS
 */
// Country Exports (birthyear, numlangs, [category], [country])
People._ensureIndex({ _id: 1, birthyear: 1, numlangs: 1, countryCode: 1});
People._ensureIndex({ _id: 1, birthyear: 1, numlangs: 1, countryCode: 1});
People._ensureIndex({ _id: 1, birthyear: 1, numlangs: 1, countryCode: 1});
People._ensureIndex({ _id: 1, birthyear: 1, numlangs: 1, domain: 1, countryCode: 1});
People._ensureIndex({ _id: 1, birthyear: 1, numlangs: 1, industry: 1, countryCode: 1});
People._ensureIndex({ _id: 1, birthyear: 1, numlangs: 1, occupation: 1, countryCode: 1});

/* 
 * TREEMAPS
 */
// Matrix (birthyear, numlangs, gender)
People._ensureIndex({ _id: 1, birthyear: 1, numlangs: 1, gender: 1});

/* 
 * TOOLTIPS
 */
// Country Exports (input: country, occupation)
this.domain_countryCode = { _id: 1, birthyear: 1, numlangs: 1, domain: 1, countryCode: 1};
this.industry_countryCode = { _id: 1, birthyear: 1, numlangs: 1, industry: 1, countryCode: 1};
this.occupation_countryCode = { _id: 1, birthyear: 1, numlangs: 1, occupation: 1, countryCode: 1};
People._ensureIndex(domain_countryCode);
People._ensureIndex(industry_countryCode);
People._ensureIndex(occupation_countryCode);

// Domain Exporters (input: country, occupation)
// People._ensureIndex({ occupation: 1, countryCode: 1, birthyear: 1, numlangs: 1});

/*
 * Need to have a prefix of all the lookups we are going to do
  * in at least one of the indices below
 */
// Imports._ensureIndex({ birthyear: 1, countryCode: 1,  occupation: 1} );
// Imports._ensureIndex({ continentName:1, countryCode: 1, occupation: 1, birthyear: 1} );
// Imports._ensureIndex({ lang_family: 1, lang: 1, occupation: 1, birthyear: 1} );
// Imports._ensureIndex({ category: 1, industry: 1, occupation: 1, birthyear: 1} );
// Imports._ensureIndex({ industry: 1} );
// Imports._ensureIndex({ occupation: 1} );
// Imports._ensureIndex({ countryCode: 1, numlangs: 1, birthyear: 1}, {background: true});
// Imports._ensureIndex({birthyear: 1, numlangs: 1});
