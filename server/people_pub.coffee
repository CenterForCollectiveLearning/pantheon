# Publications returning five individuals matching the given parameters
# Initially centered around the chosen person, though this can change based on the accordion

# TODO Make this all one publication?
# TODO Is this the best way to do this?

# Return the language editions with an article about that person
Meteor.publish "person_imports", (id) ->
    name = People.findOne(_id: id).name

    # TODO Ensure an index on name and fields!
    Imports.find(
        name: name
    ,
        fields: 
            lang: 1
            lang_name: 1
        limit: 5
    )

# TODO Change dataReady to listen to this publication
# TODO Add publications!

# Looking up people is on the server-side because minimongo is not indexed  
# Return five people with the same occupation with similar number of languages
Meteor.publish "similar_people_pub", (personName, rankingProperty) ->
    # console.log "In similar_people_pub"
    sub = this
    collectionName = "similarPeople"

    currentPersonProjection =
        HPI: 1
    currentPersonProjection[rankingProperty] = 1
    currentPerson = People.findOne({name: personName, dataset: "OGC"}, {HPI: 1})
    personHPI = currentPerson.HPI
    rankingPropertyValue = currentPerson[rankingProperty]

    # One publication with some people with an added field of "left" or "right"
    # Change projection to only pass name
    # peopleCursor = People.find({ rankingProperty: rankingPropertyValue }, { sort: { numlangs: -1} }, {name: 1}).limit(4)

    argsLeft = {HPI: {$gt: personHPI}, dataset: "OGC"}
    argsRight = {HPI: {$lt: personHPI}, dataset: "OGC"}
    argsLeft[rankingProperty] = rankingPropertyValue
    argsRight[rankingProperty] = rankingPropertyValue

    projectionLeft =
        fields:
            _id: 0
            name: 1
            HPI: 1
        sort:
            HPI: 1
        limit: 2

    projectionRight =
        fields:
            _id: 0
            name: 1
            HPI: 1
        sort:
            HPI: -1
        limit: 2

    # console.log "peoplePage args:"
    # console.log JSON.stringify(argsLeft)
    # console.log JSON.stringify(projectionLeft)

    # TODO Ensure ranking
    peopleLeft = People.find(argsLeft, projectionLeft)
    peopleRight = People.find(argsRight, projectionRight)

    rank = People.find(argsLeft).count() + 1
    # console.log "PERSON RANK", rank

    numberLeft = 2
    # TODO Create method to pad array
    if peopleLeft.count() is 1
        numberLeft = 1
        sub.added collectionName, Random.id(), 
            name: ""
            rank: -1
            position: "left"
    else if peopleLeft.count() is 0
        sub.added collectionName, Random.id(), 
            name: ""
            rank: -1
            position: "left"
        sub.added collectionName, Random.id(), 
            name: ""
            rank: -1
            position: "left"

    peopleLeft.fetch().reverse().forEach (person, i) -> 
        sub.added collectionName, Random.id(), 
            name: person.name
            rank: rank - numberLeft + i
            position: "left"

    peopleRight.forEach (person, i) -> 
        # console.log person
        sub.added collectionName, Random.id(), 
            name: person.name
            rank: rank + 1 + i
            position: "right"

    if peopleRight.count() is 1
        sub.added collectionName, Random.id(), 
            name: ""
            rank: -1
            position: "right"
    if peopleRight.count() is 0
        sub.added collectionName, Random.id(), 
            name: ""
            rank: -1
            position: "right"
        sub.added collectionName, Random.id(), 
            name: ""
            rank: -1
            position: "right"

    sub.ready()
    return