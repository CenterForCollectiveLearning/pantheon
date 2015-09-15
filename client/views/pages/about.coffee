teamMembers = [
  name: "César A. Hidalgo"
  photo: "/cesar_hidalgo.png"
  description: "Principal Investigator, Associate Professor, Head of Macro Connections"
  role: ["Concept", "Data", "Design"]
  media:
    personal: "http://chidalgo.com/"
    twitter: "https://twitter.com/cesifoti"
    linkedin: "http://www.linkedin.com/pub/cesar-a-hidalgo/5/30a/a61"
  dates: "Summer 2012 - present"
,
  name: "Amy Zhao Yu"
  photo: "/amy_yu.png"
  description: "Lead Researcher, Macro Connections PhD Candidate"
  role: ["Data", "Development", "Content"]
  media:
    personal: "http://www.amyyu.net/"
    twitter: "https://twitter.com/mangomochi86"
    linkedin: "http://www.linkedin.com/in/amyzhaoyu"
  dates: "Fall 2012 - present"
,
  name: "Kevin Zeng Hu"
  photo: "/kevin_hu.png"
  description: "PhD Candidate"
  role: ["Development", "Design", "Data"]
  media:
    personal: "http://www.kevinzenghu.com"
    twitter: "https://www.twitter.com/kevinzenghu"
    linkedin: "http://www.linkedin.com/pub/kevin-hu/58/9a7/404"
  dates: "Summer 2013 - Summer 2014"
,
  name: "Shahar Ronen"
  photo: "/shahar_ronen.png"
  description: "Graduate Alumnus"
  role: ["Data"]
  media:
    personal: "http://www.shaharronen.com/"
    twitter: "https://twitter.com/ShRonen"
    linkedin: "http://www.linkedin.com/in/shaharronen"
  dates: "Summer 2012 - Summer 2013"
,
  name: "Deepak Jagdish"
  photo: "/deepak_jagdish.png"
  description: "Graduate Alumnus"
  role: ["Design", "Video"]
  media:
    personal: "http://deepakjagdish.com/"
    twitter: "https://twitter.com/dj247"
    linkedin: "http://www.linkedin.com/pub/deepak-jagdish/5/7a/a20"
  dates: "2013 - 2014"
,
  name: "Defne Gurel"
  photo: "/defne_gurel.png"
  description: "Undergraduate"
  role: ["Data"]
  media:
    linkedin: "http://www.linkedin.com/pub/defne-gurel/63/2a0/ba6"
  dates: "2013"
,
  name: "Tiffany Lu"
  photo: "/tiffany_lu.jpg"
  description: "Undergraduate"
  role: ["Data"]
  media:
    personal: "http://tweilu.scripts.mit.edu/"
  dates: "Summer 2012"
,
  name: "Ali Almossawi"
  photo: "/ali_almossawi.jpg"
  description: "Mozilla Corporation"
  role: ["Design"]
  media:
    personal: "http://almossawi.com/"
    twitter: "https://twitter.com/alialmossawi"
    linkedin: "http://www.linkedin.com/in/almossawi/"
  dates: "2013"
,
  name: "Andrew Mao"
  photo: "/andrew_mao.png"
  description: "Graduate Student at Harvard"
  role: ["Development"]
  media:
    personal: "http://www.andrewmao.net/"
    twitter: "https://twitter.com/mizzao"
    linkedin: "www.linkedin.com/pub/andrew-mao/6/6a6/533"
  dates: "Fall 2013"
]

Template.team.helpers
  first_row_teamMembers: ->
    teamMembers.slice 0, 2

  second_row_teamMembers: ->
    teamMembers.slice 2, 5

  third_row_teamMembers: ->
    teamMembers.slice 5, 7

  fourth_row_teamMembers: ->
    teamMembers.slice 7, 9

  allteamMembers: ->
    teamMembers

Template.team.events =
  "mouseenter li.team-member": (d) ->
    srcE = (if d.srcElement then d.srcElement else d.target)
    $(srcE).find("div.info").animate
      opacity: 1.0
    , 250

  "mouseleave li.team-member": (d) ->
    srcE = (if d.srcElement then d.srcElement else d.target)
    $(srcE).find("div.info").animate
      opacity: 0.0
    , 250

Template.countrycodeSearch.settings = ->
  position: "bottom"
  limit: 10
  rules: [
    collection: Countries
    field: "countryName"
    template: Template.country_result
  ]

Template.about.rendered = ->
  b = $(document.body)
  w = $(window)

  offset = $(".logo").outerHeight() # 0 # $('.page-middle').offset().top + w.height()/4

  b.scrollspy(
    target: '#table-of-contents'
    offset: offset
    )

  Deps.autorun( ->
    scrollPosition = $(Session.get("pageScrollID")).position()?.top
    if scrollPosition then window.scrollTo(0, scrollPosition - offset - 40)
  )
  w.on('load', -> b.scrollspy('refresh'))

Template.about.render_template = ->
  section = Session.get "aboutsection"
  switch section
    when "team" then new Handlebars.SafeString(Template.team(this))
    when "vision" then new Handlebars.SafeString(Template.vision(this))
    when "permissions" then new Handlebars.SafeString(Template.permissions(this))
    when "publications" then new Handlebars.SafeString(Template.publications(this))
    when "faq" then new Handlebars.SafeString(Template.faq(this))
    when "contact" then new Handlebars.SafeString(Template.contact(this))