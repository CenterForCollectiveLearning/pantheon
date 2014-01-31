narratives = [
     domain: "ABOUT"
     title: "Visualizing Culture"
     description: "Let me show you how Pantheon works!"
     image: "pantheon_homepage.jpg"
     tutorialType: "ogc"
     guide: "/nora1.png"
 ,
    domain: "ARTS"
    title: "Explore the Renaissance"
    description: "Explore the emergence of the Renaissance!"
    image: "renaissance_homepage.jpg"
    tutorialType: "renaissance"
    guide: "/alfredo1.png"
,
    domain: "EXPLORATION"
    title: "Leaps for Humankind"
    description: "Follow the steps that led to the discovery of the world, and beyond."
    image: "explore_homepage.jpg"
    tutorialType: "moon"
    guide: "/diana.png"
,
]

Template.home.rendered = ->
    $(".flexslider").flexslider(
        namespace: "flex-"
        eventNamespace: ".flexslider"
        selector: ".slides > li"
        animation: "fade"
        easing: "swing"
        prevText: "Previous"
        nextText: "Next"
        )

Template.home.events = 
    "click #divein": (d) ->
        Router.go "/explore"

# Template.home.destroyed = ->
#     $(".logo").removeClass "gold-border"

Template.narratives.narratives = narratives

Template.narratives.events = 
    "click .learn-more": (d) ->
        srcE = (if d.srcElement then d.srcElement else d.target)
        dataTutorialType = $(srcE).data "tutorial-type"
        console.log dataTutorialType
        Session.set("tutorialType", dataTutorialType)

# Template.pages.events = 
#     "mouseenter div.page": (d) ->
#         srcE = (if d.srcElement then d.srcElement else d.target)
#         $(srcE).find("a.word").addClass("highlight")

#     "mouseleave div.page": (d) ->
#         srcE = (if d.srcElement then d.srcElement else d.target)
#         $(srcE).find("a.word").removeClass("highlight")

#     "click li a": (d) ->
#         srcE = (if d.srcElement then d.srcElement else d.target)  
#         vizType = $(srcE).parent().data "viz-type"  # Need parent() since img is target
#         vizMode = $(srcE).parent().data "viz-mode"

#         # Parameters depend on vizMode (e.g countries -> languages for exports)
#         [paramOne, paramTwo] = IOMapping[vizMode]["in"]
    
#         # Reset parameters for a viz type change
#         Router.go "observatory",
#         vizType: vizType
#         vizMode: vizMode
#         paramOne: defaults[paramOne]
#         paramTwo: defaults[paramTwo]
#         from: defaults.from
#         to: defaults.to
#         langs: defaults.langs
#         dataset: defaults.dataset
