Template.ranking_table.rendered = ->
  entity = Session.get("entity")
  switch entity
    when "countries"
      data = _.map CountriesRanking.find().fetch(), (c) ->
        [0, c.countryName, c.numppl, c.percentwomen, c.diversity, c.i50, c.Hindex]
      aoColumns = [
        sTitle: "Ranking"
      ,
        sTitle: "Country"
      ,
        sTitle: "Number of People"
      ,
        sTitle: "% Women"
      ,
        sTitle: "Diversity"
      ,
        sTitle: "i50"
      ,
        sTitle: "H-index"
      ]
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
      data = _.map DomainsRanking.find().fetch(), (d) ->
        [0, d.occupation.capitalize(), d.industry.capitalize(), d.domain.capitalize(), d.ubiquity, d.percentwomen, d.numppl]
      aoColumns = [
        sTitle: "Ranking"
      ,
        sTitle: "Occupation"
      ,
        sTitle: "Industry"
      ,
        sTitle: "Domain"
      ,
        sTitle: "Total Exporters"
      ,
        sTitle: "% Women"
      ,
        sTitle: "Total People"
      ]

  #initializations
  $("#ranking").dataTable
    aoColumns: aoColumns
    aaData: data
    aaSorting: [[6, "desc"], [1, "asc"]]  # Multi-column sort on L then name
    iDisplayLength: 25
    bDeferRender: false
    bSortClasses: false
    bSorted: false
    sDom: "Rlfrtip"
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

    aoColumnDefs: [
      bSortable: false
      aTargets: [0]
    ]
    

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

  $(@find("select")).chosen()

Template.ranking_table.events = "mouseleave th": (d) ->
  document.getElementById("tooltip").className = "invisible"