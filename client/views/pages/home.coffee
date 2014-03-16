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
        after: ->
            renaissance_current = false
            $(".flexslider li.tutorial-li").each( ->
                zindex = $(this).zIndex() 
                id = $(this)[0].id
                if zindex is 2 and id is "renaissance" 
                    renaissance_current = true
            )
            if renaissance_current
                $("span.video-label").animate({color: "#222222"}, "slow")
            else
                $("span.video-label").animate({color: "#f9f6e1"}, "slow")
        )

Template.home.events = 
    "click #divein": (d) ->
        Router.go "/viz"

Template.narratives.narratives = ->
    if Session.equals("mobile", true)
        [narratives[0]]
    else
        narratives

Template.narratives.events = 
    "click .learn-more": (d) ->
        if Session.equals("mobile", false)
            srcE = (if d.srcElement then d.srcElement else d.target)
            dataTutorialType = $(srcE).data "tutorial-type"
            Session.set("tutorialType", dataTutorialType)
        else
            Router.go "/viz"