Template.ranking_table.rendered = ->
  entity = Session.get("entity")
  switch entity
    when "countries"
      console.log CountriesRanking.find().fetch()
    when "people"
      data = _.map PeopleTopN.find().fetch(), (d) ->
        p = People.findOne d._id
        [0, p.name, p.countryName, p.birthyear, p.gender, p.occupation.capitalize(), p.numlangs]
      aoColumns = [
        sTitle: "Ranking"
      ,
        sTitle: "Name"
        fnRender: (obj) -> "<a class='closeclicktooltip' href='/people/" + obj.aData[obj.iDataColumn] + "'>" + obj.aData[obj.iDataColumn] + "</a>"  # Insert route here
      ,
        sTitle: "Country"
      ,
        sTitle: "Birth Year"
      ,
        sTitle: "Gender"
      ,
        sTitle: "Occupation"
      ,
        sTitle: "L"
      ]
    when "domains"
      console.log DomainsRanking.find().fetch()

  #initializations
  $("#ranking").dataTable
    aaData: data
    aoColumns: aoColumns
    iDisplayLength: 25
    bDeferRender: true
    bSortClasses: false
    fnDrawCallback: (oSettings) ->
      that = this

      # Redo for sorted AND filtered...
      # if ( oSettings.bSorted || oSettings.bFiltered )
      # Only redo for sorted, not filtered (ie. you can search/filter and ranking stays stable)
      if oSettings.bSorted
        @$("td:first-child",
          filter: "applied"
        ).each (i) ->
          that.fnUpdate i + 1, @parentNode, 0, false, false

    # aoColumnDefs: [
    #   bSortable: false
    #   aTargets: [0]
    # ]
    aaSorting: [[6, "desc"]]

#  Render a basic tooltip for the column headers
  $("th").on mousemove: (e) ->
    x = e.pageX
    y = e.pageY
    se = e.srcElement or e.target
    content = e.srcElement.getAttribute("name")
    document.getElementById("tooltip").innerHTML = content
    window.lastX = e.pageX
    window.lastY = e.pageY
    ttOffset = 10
    lastX = window.lastX + ttOffset
    lastY = window.lastY + ttOffset
    tt = document.getElementById("tooltip")
    tt.className = "visible"
    tt.style.left = lastX + "px"
    tt.style.top = lastY + "px"
    tt.style.fontSize = "10pt"
    tt.style.zIndex = "100"

Template.ranking_accordion.rendered = ->
  mapping =
    countries: 0
    people: 1
    domains: 2

  accordion = $(".accordion")
  accordion.accordion
    active: mapping[Session.get("entity")]
    collapsible: false
    heightStyle: "content"
    fillSpace: false

  # accordion.accordion "resize"

Template.ranking_accordion.events = "click h3": (d) ->
  srcE = (if d.srcElement then d.srcElement else d.target)
  option = $(srcE).attr("id")
  modeToEntity =
    country_ranking: "countries"
    people_ranking: "people"
    domains_ranking: "domains"

  category = defaults.category
  
  # Reset parameters for a viz type change
  category = "EXPLORATION"  if option is "people_ranking" #TODO: all people ranking is SLOW.... default to astronauts now
  path = "/rankings/" + modeToEntity[option] + "/" + defaults.country + "/" + category + "/" + defaults.from + "/" + defaults.to
  Router.go path

Template.ranking_table.render_table = ->
  entity = Session.get("entity")
  switch entity
    when "countries"
      return new Handlebars.SafeString(Template.ranked_countries_list(this))
    when "people"
      return new Handlebars.SafeString(Template.ranked_people_list(this))
    when "domains"
      return new Handlebars.SafeString(Template.ranked_domains_list(this))

Template.ranking_table.render_cols = ->
  entity = Session.get("entity")
  switch entity
    when "countries"
      new Handlebars.SafeString(Template.country_cols(this))
    when "people"
      new Handlebars.SafeString(Template.ppl_cols(this))
    when "domains"
      return new Handlebars.SafeString(Template.dom_cols(this))

Template.ranked_people_list.people_full_ranking = ->
  console.log "IN People_full_ranking"
  if(Session.get "clicktooltip")
    console.log "got clicktooltip"
    Tooltips.find _id:
      $not: "count"
  else
    console.log "did not get clicktooltip"
    PeopleTopN.find()

Template.ranked_ppl.occupation = ->
  @occupation.capitalize()

Template.ranked_countries_list.countries_full_ranking = ->
  CountriesRanking.find()

Template.ranked_domains_list.domains_full_ranking = ->
  DomainsRanking.find()

# TODO: do this with CSS instead??
Template.ranked_domain.occupation = ->
  @occupation.capitalize()

Template.ranked_domain.industry = ->
  @industry.capitalize()

Template.ranked_domain.domain = ->
  @domain.capitalize()

Template.ranking_table.events = "mouseleave th": (d) ->
  document.getElementById("tooltip").className = "invisible"