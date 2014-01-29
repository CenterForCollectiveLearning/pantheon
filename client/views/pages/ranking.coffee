toMillions = (x) ->
  String((x/1000000).toFixed(2)) + " M"

toThousands = (x) ->
  String((x/1000).toFixed(2)) + " K"

fnShowHide = (iCol) ->  
  # Get the DataTables object again - this is not a recreation, just a get of the object 
  oTable = $("#ranking").dataTable()
  bVis = oTable.fnSettings().aoColumns[iCol].bVisible
  oTable.fnSetColumnVis iCol, (if bVis then false else true)

Template.rankings.columnDescriptions = ->
  entity = Session.get "entity"
  switch entity
    when "countries"
      new Handlebars.SafeString(Template.countries_columns(this))
    when "people"
      new Handlebars.SafeString(Template.people_columns(this))
    when "domains"
      new Handlebars.SafeString(Template.domains_columns(this))

Template.ranking_table.rendered = ->
  # for sorting formatted numbers
  jQuery.extend jQuery.fn.dataTableExt.oSort,
    "formatted-num-pre": (a) ->
      a = (if (a is "-" or a is "") then 0 else a.replace(/[^\d\-\.]/g, ""))
      parseFloat a
    "formatted-num-asc": (a, b) ->
      a - b
    "formatted-num-desc": (a, b) ->
      b - a 
  clickTooltip = Session.get("clicktooltip")
  entity = Session.get("entity")
  dataset = Session.get("dataset")
  if clickTooltip
    entity = "people"

  console.log "IN RANKING_TABLE TEMPLATE", clickTooltip, entity, dataset
  
  switch entity
    when "countries"
      data = _.map CountriesRanking.find().fetch(), (c) ->
        [0, c.countryName, c.numppl, c.percentwomen, c.diversity, c.i50, c.Hindex, c.HCPI.toFixed(0)]
      aoColumns = [
        sTitle: "Rank"
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
      ,
        sTitle: "HCPI"
      ]
    when "people"
      console.log "IN PEOPLE, clickTooltip: ", clickTooltip
      if clickTooltip then collection = Tooltips.find({_id: {$not: "count"}}).fetch()
      else collection = PeopleTopN.find().fetch()
      console.log "COLLECTION", collection

      data = _.map collection, (d) ->
        p = People.findOne d._id
        if dataset is "OGC"
          [0, p.name, p.countryName, p.birthyear, p.gender, p.occupation.capitalize(), p.numlangs, p.L_star.toFixed(0), toMillions(p.TotalPageViews), toMillions(p.PageViewsEnglish), toMillions(p.PageViewsNonEnglish), toThousands(p.StdDevPageViews), p.HPI.toFixed(0)]
        else
          [0, p.name, p.countryName, p.birthyear, p.gender, p.occupation.capitalize(), p.numlangs]

      if dataset is "murray"
        aoColumns = [
          sTitle: "Rank"
        ,
          sTitle: "Name"
        ,
          sTitle: "Country of Birth"
        ,
          sTitle: "Birth Year"
        ,
          sTitle: "Gender"
        ,
          sTitle: "Occupation"
        ,
          sTitle: "Index"
        ]
      else
        aoColumns = [
          sTitle: "Rank"
        ,
          sTitle: "Name"
          fnRender: (obj) -> "<a class='closeclicktooltip' href='/people/" + obj.aData[obj.iDataColumn] + "'>" + obj.aData[obj.iDataColumn] + "</a>"  # Insert route here
        ,
          sTitle: "Country of Birth"
        ,
          sTitle: "Birth Year"
        ,
          sTitle: "Gender"
        ,
          sTitle: "Occupation"
        ,
          sTitle: "L"
        , 
          sTitle: "L*"
        , 
          {sTitle: "Page Views", sType: "formatted-num"}
        , 
          {sTitle: "English Page Views", sType: "formatted-num"}
        , 
          {sTitle: "Non-English Page Views", sType: "formatted-num"}
        , 
          {sTitle: "Standard Deviation of Page Views", sType: "formatted-num"}
        , 
          sTitle: "HPI"
        ]
    when "domains"
      data = _.map DomainsRanking.find().fetch(), (d) ->
        [0, d.occupation.capitalize(), d.industry.capitalize(), d.domain.capitalize(), d.ubiquity, d.percentwomen, d.numppl]
      aoColumns = [
        sTitle: "Rank"
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

  if clickTooltip then displayLength = 10
  else 
    displayLength = 100

  #initializations
  sorting = switch
    when entity is "countries" then [[7, "desc"]]
    when entity is "people" and dataset is "OGC" then [[12, "desc"], [1, "asc"]] 
    else [[6, "desc"], [1, "asc"]]  # Multi-column sort on L then name

  oTable = $("#ranking").dataTable
    sScrollY: "600px"
    aoColumns: aoColumns
    aaData: data
    aaSorting: sorting
    iDisplayLength: displayLength
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

  $(window).bind "resize", ->
    oTable.fnAdjustColumnSizing()

  $(@find("select")).chosen()
