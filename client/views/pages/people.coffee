Template.people.helpers 
  name: -> 
  	name = People.findOne name: Session.get("name")


Template.person.helpers
  gender: ->
  	if this.gender is "Male" then "He" else "She"
  occupation: -> this.occupation.capitalize()


Template.person.events
  "mouseenter .country-name": -> $(".people-accordion").accordion('activate', 2)
  "mouseenter .occupation": -> $(".people-accordion").accordion('activate', 0)
  "mouseenter .birthyear": -> $(".people-accordion").accordion('activate', 1)


# TODO Map to search icon
Template.person_name.settings = ->
  position: "bottom"
  limit: 5
  rules: [
    token: ""  # No token (TODO if not provided, assume none)
    collection: People
    field: "name"
    template: Template.user_pill
  ]

Template.people_accordion.events = 
  "mouseenter li.person": (d) ->
    srcE = (if d.srcElement then d.srcElement else d.target)
    $(srcE).find("div.top-info").addClass("hovered")
    $(srcE).find("div.bottom-info").addClass("hovered")

  "mouseleave li.person": (d) ->
    srcE = (if d.srcElement then d.srcElement else d.target)
    $(srcE).find("div.top-info").removeClass("hovered")
    $(srcE).find("div.bottom-info").removeClass("hovered")

$(window).load( ->
  )

# TODO Why is this calling /so/ many times?
Template.people_accordion.rendered = ->
  accordion = $(".people-accordion")
  accordion.accordion
    active: 0
    collapsible: false
    heightStyle: "content"
    fillSpace: false
  # accordion.accordion "resize"

  # How to only display after setting?

  # Maximum width
  maximumWidth = $('div.person-image-container').first().width()
  console.log "maximumWidth", maximumWidth

  # Resize images intelligently
  # div.ui-accordion-content-active 
  finalAspectRatio = 4/3
  $('img.person-image').each((index) ->
    image = $(this)
    imageContainer = $(this).parent().parent()

    width = image.width()
    height = image.height()
    aspectRatio = height / width
    taller = aspectRatio > finalAspectRatio

    console.log index, aspectRatio
    if width

      # TODO Allow some fudge ratio
  
      # If taller than aspect ratio, then fit width and crop bottom
      # Test case: http://localhost:3000/people/Paul%20of%20Tarsus
      if taller
        imageContainer.css({"max-height": finalAspectRatio * maximumWidth, "overflow": "hidden"})
        image.css({"width": "100%", "height": "auto"})
      # If wider than aspect ratio, fit height and crop sides
      # Test case: http://localhost:3000/people/Bernhard%20Riemann
      else
        overflowXAmount = width - maximumWidth
        imageContainer.css({"height": finalAspectRatio * maximumWidth, "overflow-x": "hidden"})
        image.css({"width": "auto", "max-width": "none", "height": "100%", "margin-left": -overflowXAmount / 2})
  )

Template.people_accordion.helpers
  occupation: -> this.occupation.capitalize() + "s"
  time_period: -> this.birthyear
  # TODO Expose global date mapping, if notable time period or decade then state
  personImports: -> 
    Session.set "personID", this._id
    console.log "PERSON IMPORTS", Imports.find().fetch()
    Imports.find()
  occupationPeople: -> 
    Session.set "personID", this._id
    Session.set "personOccupation", this.occupation
    OccupationPeople.find()
  birthyearPeople: -> 
    Session.set "personID", this._id
    Session.set "personBirthyear", this.birthyear
    BirthyearPeople.find()
    # People.find({birthyear: this.birthyear}, {limit: 5})
  countryPeople: -> 
    Session.set "personID", this._id
    Session.set "personCountry", this.countryName
    CountryPeople.find()