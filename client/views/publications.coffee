toc = [
  name: "The Structure and Dynamics of Global Cultural Development"
  type: "title"
, ["Abstract", "Introduction", "Data and Methods", "Results"],
  type: "spacer"
,
  name: "Communication Technologies as Agents of Fame"
  type: "title" #: What 11,000 Biographies can tell us about our Collective Memory", [
, ["Abstract", "Introduction", "Data and Methods", "Results"]]
name_to_id = (name) ->
  x = name.toLowerCase().replace(/[^a-z0-9_,.]/g, "").replace(/[,.]/g, "_")
  x


# TODO: Make scrolling work
# TODO: SIMPLIFY THIS CODE!!!
Template.publications.rendered = ->
  console.log "RENDERING PUBLICATIONS TEMPLATE"
  
  # TODO How do you get this to re-run?
  # $.cachedScript('http://www.readrboard.com/static/engage.js').done(function() {
  #     console.log( "Received Script" );
  # });
  scrollToSection = (section) ->
    return  unless $(section).length
    ignore_waypoints = true
    Session.set "section", section.substr(1)
    scroller().animate
      scrollTop: $(section).offset().top
    , 500, "swing", ->
      window.location.hash = section
      ignore_waypoints = false


  
  # returns a jQuery object suitable for setting scrollTop to
  # scroll the page, either directly for via animate()
  scroller = ->
    $("div.page-middle").stop()

  sections = []
  _.each $(".publication h1, .publication h2, .publication h3"), (elt) ->
    classes = (elt.getAttribute("class") or "").split(/\s+/)
    sections.push elt  if _.indexOf(classes, "nosection") is -1

  console.log sections
  i = 0

  while i < sections.length
    
    # var classes = (sections[i].getAttribute('class') || '').split(/\s+/);
    # console.log(classes);
    # if (_.indexOf(classes, "nosection") !== -1)
    #  continue;
    sections[i].prev = sections[i - 1] or sections[i]
    sections[i].next = sections[i + 1] or sections[i]
    $(sections[i]).waypoint offset: 30
    console.log sections[i]
    i++
  section = document.location.hash.substr(1) or sections[0].id
  Session.set "section", section
  if section
    
    # WebKit will scroll down to the #id in the URL asynchronously
    # after the page is rendered, but Firefox won't.
    Meteor.setTimeout (->
      elem = $("#" + section)
      scroller().scrollTop elem.offset().top  if elem.length
    ), 0
  ignore_waypoints = false
  $("body").delegate "h1, h2, h3", "waypoint.reached", (evt, dir) ->
    unless ignore_waypoints
      active = (if (dir is "up") then @prev else this)
      Session.set "section", active.id

  window.onhashchange = ->
    scrollToSection location.hash

  $("#main, #nav").delegate "a[href^='#']", "click", (evt) ->
    evt.preventDefault()
    sel = $(this).attr("href")
    scrollToSection sel
    mixpanel.track "docs_navigate_" + sel

  
  # Make external links open in a new tab.
  $("a:not([href^=\"#\"])").attr "target", "_blank"


# TODO: Options if not on that paper
# Convert toc into a list of {id, name, type, depth}
Template.sidenav.sections = ->
  ret = []
  walk = (items, depth) ->
    _.each items, (item) ->
      unless item instanceof Array
        item = name: item  if typeof (item) is "string"
        ret.push _.extend(
          type: "section"
          id: item.name and name_to_id(item.name) or `undefined`
          depth: depth
        , item)


  walk toc, 1
  console.log ret
  ret

Template.sidenav.type = (what) ->
  @type is what

Template.sidenav.maybe_current = ->
  (if Session.equals("section", @id) then "current" else "")