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

# TODO Combine these into one publication?

# Return five people with the same occupation with similar number of languages
Meteor.publish "occupation_pub", (id, occupation) ->
    sub = this
    collectionName = "occupationPeople"

    # Write this query to not resort every time
    peopleCursor = People.find({ occupation: occupation }, { sort: { numlangs: -1} }) #, sort: numlangs: -1).fetch()
    peopleCount = peopleCursor.count()
    people = peopleCursor.fetch()

    # Get index of individual
    centerIndex = 0
    for d, i in people 
        d.rank = i + 1
        if d._id.equals(id) then centerIndex = i
    # TODO Exit out of this if not found

    # Add ranks dynamically

    # If in first two, just return first five
    if centerIndex < 2 then result = people.slice(0, 5)

    # If in last two, just return last five
    else if centerIndex > (peopleCount - 3) then result = people.slice(peopleCount - 5, peopleCount)

    else result = people.slice(centerIndex - 2, centerIndex + 3)

    _.each result, (person) -> 
        sub.added collectionName, person._id, person

    sub.ready()

# Return five people from similar birthyears
Meteor.publish "birthyear_pub", (id, birthyear) ->
    sub = this
    collectionName = "birthyearPeople"

    console.log "BIRTHYEAR", birthyear
    peopleCursor = People.find({}, { sort: { birthyear: -1, numlangs: -1} })
    peopleCount = peopleCursor.count()
    people = peopleCursor.fetch()

    # Get index of individual
    centerIndex = 0
    for d, i in people 
        d.rank = i + 1
        if d._id.equals(id) then centerIndex = i
    # TODO Exit out of this if not found

    # Add ranks dynamically

    # If in first two, just return first five
    if centerIndex < 2 then result = people.slice(0, 5)

    # If in last two, just return last five
    else if centerIndex > (peopleCount - 3) then result = people.slice(peopleCount - 5, peopleCount)

    else result = people.slice(centerIndex - 2, centerIndex + 3)

    _.each result, (person) -> 
        sub.added collectionName, person._id, person

    sub.ready()
# Return five people from the same country with similar number of languages
Meteor.publish "country_pub", (id, countryName) ->
    sub = this
    collectionName = "countryPeople"

    peopleCursor = People.find({ countryName: countryName }, { sort: { numlangs: -1} }) #, sort: numlangs: -1).fetch()
    peopleCount = peopleCursor.count()
    people = peopleCursor.fetch()

    # Get index of individual
    centerIndex = 0
    for d, i in people 
        d.rank = i + 1
        if d._id.equals(id) then centerIndex = i
    # TODO Exit out of this if not found

    # If in first two, just return first five
    if centerIndex < 2 then result = people.slice(0, 5)

    # If in last two, just return last five
    else if centerIndex > (peopleCount - 3) then result = people.slice(peopleCount - 5, peopleCount)

    else result = people.slice(centerIndex - 2, centerIndex + 3)

    _.each result, (person) -> 
        sub.added collectionName, person._id, person

    sub.ready()

# Meteor.publish "gender_pub", (id, gender) ->
#     return