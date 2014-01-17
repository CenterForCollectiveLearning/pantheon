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
  clickTooltip = Session.get("clicktooltip")
  entity = Session.get("entity")
  dataset = Session.get("dataset")
  if clickTooltip
    entity = "people"

  console.log "IN RANKING_TABLE TEMPLATE", clickTooltip, entity, dataset
  
  switch entity
    when "countries"
      data = _.map CountriesRanking.find().fetch(), (c) ->
        [0, c.countryName, c.numppl, c.percentwomen, c.diversity, c.i50, c.Hindex, c.HCPI]
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
          [0, p.name, p.countryName, p.birthyear, p.gender, p.occupation.capitalize(), p.numlangs, p.L_star.toFixed(2), p.TotalPageViews, p.PageViewsEnglish, p.PageViewsNonEnglish, p.StdDevPageViews.toFixed(2), p.HPI.toFixed(2)]
        else
          [0, p.name, p.countryName, p.birthyear, p.gender, p.occupation.capitalize(), p.numlangs]

      if dataset is "murray"
        aoColumns = [
          sTitle: "Ranking"
        ,
          sTitle: "Name"
        ,
          sTitle: "Country"
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
        , 
          sTitle: "L*"
        , 
          sTitle: "Page Views"
        , 
          sTitle: "English Page Views"
        , 
          sTitle: "Non-English Page Views"
        , 
          sTitle: "Standard Deviation of Page Views"
        , 
          sTitle: "HPI"
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

  if clickTooltip then displayLength = 10
  else 
    if entity is "countries" then displayLength = 100
    else displayLength = 25

  #initializations
  sorting = switch
    when entity is "countries" then [[7, "desc"]]
    when entity is "people" and dataset is "OGC" then [[12, "desc"], [1, "asc"]] 
    else [[6, "desc"], [1, "asc"]]  # Multi-column sort on L then name

  $("#ranking").dataTable
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

  $(@find("select")).chosen()
