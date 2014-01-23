teamMembers = [
  name: "César A. Hidalgo"
  photo: "images/cesar_hidalgo.png"
  description: "Principal Investigator"
  role: ["Concept", "Data", "Design"]
  media:
    personal: "http://chidalgo.com/"
    twitter: "https://twitter.com/cesifoti"
    linkedin: "http://www.linkedin.com/pub/cesar-a-hidalgo/5/30a/a61"
,
  name: "Amy Zhao Yu"
  photo: "images/amy_yu.png"
  description: "Graduate Student"
  role: ["Data", "Content", "Development"]
  media:
    personal: "http://www.amyyu.net/"
    twitter: "https://twitter.com/mangomochi86"
    linkedin: "http://www.linkedin.com/in/amyzhaoyu"
,
  name: "Kevin Zeng Hu"
  photo: "images/kevin_hu.png"
  description: "Graduate Student"
  role: ["Development", "Design", "Data"]
  media:
    personal: "http://www.kevinzenghu.com"
    twitter: "https://www.twitter.com/kevinzenghu"
    linkedin: "http://www.linkedin.com/pub/kevin-hu/58/9a7/404"
,
  name: "Ali Almossawi"
  photo: "images/ali_almossawi.jpg"
  description: "Mozilla Corporation"
  role: ["Design"]
  media:
    personal: "http://almossawi.com/"
    twitter: "https://twitter.com/alialmossawi"
    linkedin: "http://www.linkedin.com/in/almossawi/"
,
  name: "Shahar Ronen"
  photo: "images/shahar_ronen.png"
  description: "Graduate Alumnus"
  role: ["Data"]
  media:
    personal: "http://www.shaharronen.com/"
    twitter: "https://twitter.com/ShRonen"
    linkedin: "http://www.linkedin.com/in/shaharronen"
,
  name: "Deepak Jagdish"
  photo: "images/deepak_jagdish.png"
  description: "Graduate Student"
  role: ["Design", "Video"]
  media:
    personal: "http://deepakjagdish.com/"
    twitter: "https://twitter.com/dj247"
    linkedin: "http://www.linkedin.com/pub/deepak-jagdish/5/7a/a20"
,
  name: "Andrew Mao"
  photo: "images/andrew_mao.png"
  description: "Graduate Student at Harvard"
  role: ["Development"]
  media:
    personal: "http://www.andrewmao.net/"
    twitter: "https://twitter.com/mizzao"
    linkedin: "www.linkedin.com/pub/andrew-mao/6/6a6/533"
,
  name: "Defne Gurel"
  photo: "images/defne_gurel.png"
  description: "Computer Science Undergraduate"
  role: ["Data"]
  media:
    linkedin: "http://www.linkedin.com/pub/defne-gurel/63/2a0/ba6"
,
  name: "Tiffany Lu"
  photo: "images/tiffany_lu.jpg"
  description: "Computer Science Undergraduate"
  role: ["Data"]
  media:
    personal: "http://tweilu.scripts.mit.edu/"
]
Template.team.helpers
  first_row_teamMembers: ->
    teamMembers.slice 0, 3

  second_row_teamMembers: ->
    teamMembers.slice 3, 6

  third_row_teamMembers: ->
    teamMembers.slice 6, 9

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