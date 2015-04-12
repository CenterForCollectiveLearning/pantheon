toMillions = (x) ->
  String((x/1000000).toFixed(2)) + " M"

toThousands = (x) ->
  String((x/1000).toFixed(2)) + " K"

toDecimal = (x, d) ->
  if typeof x is "string" or x instanceof String
    parseFloat(x)?.toFixed d
  else
    x?.toFixed d

Template.message_update.events
  "click button.close": ->
    Session.set "alert", false

Template.rankings.rendered = ->
  # keep showing menu unless user collapses the search parameters
  if Session.equals("showMobileRankingMenu", true)
    $(".fa-search-plus").hide()
    $(".fa-search-minus").show()
    $(".parameters").show()

Template.rankings.entity = ->
  entity = Session.get "entity"
  switch entity
    when "countries"
      "Place of Birth*"
    when "people"
      "People"
    when "domains"
      "Domain"

Template.rankings.columnDescriptions = ->
  entity = Session.get "entity"
  switch entity
    when "countries"
      Template.countries_columns
    when "people"
      Template.people_columns
    when "domains"
      Template.domains_columns

Template.rankings.rankingdataReady = ->
  entity = Session.get "entity"
  switch entity
    when "countries", "domains"
      Session.equals "dataReady", true
    when "people"
      Session.equals("peopleReady", true) and Session.equals("dataReady", true)

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
  mobile = Session.get("mobile")
  entity = Session.get("entity")
  dataset = Session.get("dataset")
  if clickTooltip
    entity = "people"

  switch entity
    when "countries"
      if mobile
        data = _.map CountriesRanking.find().fetch(), (c) ->
          [0, c.countryName, c.numppl, toDecimal(c.HCPI, 0)]
        aoColumns = [
          sTitle: "Rank"
        ,
          sTitle: "Place of Birth*"
          fnRender: (obj) -> "<a class='closeclicktooltip' href='/treemap/country_exports/" + Countries.findOne({countryName : obj.aData[obj.iDataColumn]}, {})?["countryCode"] + "/all/" + Session.get("from") + "/" + Session.get("to") + "/" + Session.get("langs") + "/OGC" + "'>" + obj.aData[obj.iDataColumn] + "</a>"  # Insert route here
        ,
          sTitle: "Number of People"
        ,
          sTitle: "HCPI"
        ]
      else
        data = _.map CountriesRanking.find().fetch(), (c) ->
          [0, c.countryName, c.numppl, c.percentwomen, c.diversity, c.i50, c.Hindex, toDecimal(c.HCPI, 2)]
        aoColumns = [
          sTitle: "Rank"
        ,
          sTitle: "Place of Birth*"
          fnRender: (obj) -> "<a class='closeclicktooltip' href='/treemap/country_exports/" + Countries.findOne({countryName : obj.aData[obj.iDataColumn]}, {})?["countryCode"] + "/all/" + Session.get("from") + "/" + Session.get("to") + "/" + Session.get("langs") + "/OGC" + "'>" + obj.aData[obj.iDataColumn] + "</a>"  # Insert route here
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
      if clickTooltip
        collection = Tooltips.find({_id: {$not: "count"}}).fetch()
      else 
          args =
            birthyear:
              $gte: parseInt(Session.get("from"))
              $lte: parseInt(Session.get("to"))
          country = Session.get("country")
          args.countryCode = country if country isnt "all"
          args.dataset = "OGC"
          category = Session.get("category")
          args[Session.get("categoryLevel")] = category if category.toLowerCase() isnt "all"
          L = Session.get("langs")
          if L[0] is "H" then args.HPI = {$gt:parseInt(L.slice(1,L.length))} else args.numlangs = {$gt: parseInt(L)}
          collection = ClientPeople.find(args, {sort:{'HPI':-1}}).fetch()

      data = _.map collection, (d, i) -> #add i for the index, set it intially because we use deferred rendering (sort collection by HPI - see above)
        p = ClientPeople.findOne d._id
        if dataset is "OGC" and clickTooltip
          [i+1, p.name, p.birthyear, p.gender, p.occupation.capitalize(), p.numlangs, toDecimal(p.L_star,0), toMillions(p.TotalPageViews), toDecimal(p.HPI,2)]  
        else if Session.equals("page", "rankings") and mobile
          [i+1, p.name, p.birthyear, p.countryCode, p.occupation.capitalize(), toDecimal(p.HPI,2)]  
        else if dataset is "OGC" and not mobile
          [i+1, p.name, p.countryName, p.birthyear, p.gender, p.occupation.capitalize(), p.numlangs, toDecimal(p.L_star,1), toMillions(p.TotalPageViews), toMillions(p.PageViewsEnglish), toMillions(p.PageViewsNonEnglish), toThousands(p.StdDevPageViews), toDecimal(p.HPI,3)]
        else
          [i+1, p.name, p.countryName, p.birthyear, p.gender, p.occupation.capitalize(), p.numlangs]

      if dataset is "murray"
        aoColumns = [
          sTitle: "Rank"
        ,
          sTitle: "Name"
        ,
          sTitle: "Place of Birth*"
        ,
          sTitle: "Birth Year"
        ,
          sTitle: "Gender"
        ,
          sTitle: "Occupation"
        ,
          sTitle: "Index"
        ]
      else if clickTooltip
        aoColumns = [
          sTitle: "Rank"
        ,
          sTitle: "Name"
          fnRender: (obj) -> "<a class='closeclicktooltip' href='/people/" + obj.aData[obj.iDataColumn] + "'>" + obj.aData[obj.iDataColumn] + "</a>"  # Insert route here
          sWidth: "20%"
        ,
          sTitle: "Birth Year"
        ,
          sTitle: "Gender"
        ,
          sTitle: "Occupation"
          sWidth: "15%"
        ,
          sTitle: "L"
          sWidth: "8%"
        , 
          sTitle: "L*"
          sWidth: "8%"
        , 
          {sTitle: "Page Views", sType: "formatted-num"}
        , 
          sTitle: "HPI"
        ]
      else if mobile
        aoColumns = [
          sTitle: "Rank"
        ,
          sTitle: "Name"
          fnRender: (obj) -> "<a class='closeclicktooltip' href='/people/" + obj.aData[obj.iDataColumn] + "'>" + obj.aData[obj.iDataColumn] + "</a>"  # Insert route here
        ,
          sTitle: "Birth Year"
        ,
          sTitle: "Place of Birth*"
        ,
          sTitle: "Domain"
        , 
          sTitle: "HPI"
        ]
      else
        aoColumns = [
          sTitle: "Rank"
        ,
          sTitle: "Name"
          fnRender: (obj) -> "<a class='closeclicktooltip' href='/people/" + obj.aData[obj.iDataColumn] + "'>" + obj.aData[obj.iDataColumn] + "</a>"  # Insert route here
          sWidth: "12%"
        ,
          sTitle: "Place of Birth*"
          sWidth: "9%"
        ,
          sTitle: "Birth Year"
          sWidth: "8%"
        ,
          sTitle: "Gender"
          sWidth: "8%"
        ,
          sTitle: "Occupation"
          sWidth: "10%"
        ,
          sTitle: "L"
        , 
          sTitle: "L*"
        , 
          {sTitle: "PV", sType: "formatted-num"}
        , 
          {sTitle: "PV<sub>e</sub>", sType: "formatted-num"}
        , 
          {sTitle: "PV<sub>ne</sub>", sType: "formatted-num"}
        , 
          {sTitle: "&sigma;<sub>PV</sub>", sType: "formatted-num"}
        , 
          sTitle: "HPI"
        ]
    when "domains"
      if mobile
        data = _.map DomainsRanking.find().fetch(), (d) ->
          [0, d.occupation.capitalize(), d.ubiquity, d.numppl]
        aoColumns = [
          sTitle: "Rank"
        ,
          sTitle: "Occupation"
          fnRender: (obj) -> "<a class='closeclicktooltip' href='/treemap/domain_exports_to/" + obj.aData[obj.iDataColumn].toUpperCase() + "/all/" + Session.get("from") + "/" + Session.get("to") + "/" + Session.get("langs") + "/OGC" + "'>" + obj.aData[obj.iDataColumn] + "</a>"  # Insert route here
        ,
          sTitle: "Total Exporters"
        ,
          sTitle: "Total People"
        ]
      else
        data = _.map DomainsRanking.find().fetch(), (d) ->
          [0, d.occupation.capitalize(), d.industry.capitalize(), d.domain.capitalize(), d.ubiquity, d.percentwomen, d.numppl]
        aoColumns = [
          sTitle: "Rank"
        ,
          sTitle: "Occupation"
          fnRender: (obj) -> "<a class='closeclicktooltip' href='/treemap/domain_exports_to/" + obj.aData[obj.iDataColumn].toUpperCase() + "/all/" + Session.get("from") + "/" + Session.get("to") + "/" + Session.get("langs") + "/OGC" + "'>" + obj.aData[obj.iDataColumn] + "</a>"  # Insert route here
        ,
          sTitle: "Industry"
          fnRender: (obj) -> "<a class='closeclicktooltip' href='/treemap/domain_exports_to/" + obj.aData[obj.iDataColumn].toUpperCase() + "/all/" + Session.get("from") + "/" + Session.get("to") + "/" + Session.get("langs") + "/OGC" + "'>" + obj.aData[obj.iDataColumn] + "</a>"  # Insert route here
        ,
          sTitle: "Domain"
          fnRender: (obj) -> "<a class='closeclicktooltip' href='/treemap/domain_exports_to/" + obj.aData[obj.iDataColumn].toUpperCase() + "/all/" + Session.get("from") + "/" + Session.get("to") + "/" + Session.get("langs") + "/OGC" + "'>" + obj.aData[obj.iDataColumn] + "</a>"  # Insert route here
        ,
          sTitle: "Total Exporters"
        ,
          sTitle: "% Women"
        ,
          sTitle: "Total People"
        ]

  #initializations
  sorting = switch
    when entity is "countries" 
      if mobile
        [[3, "desc"]]
      else
        [[7, "desc"]]
    when entity is "people" 
      if dataset is "OGC" and not clickTooltip and not mobile then [[12, "desc"]] 
      else if clickTooltip then [[8, "desc"]]
      else if mobile then [[5, "desc"]]
    when entity is "domains"
      if mobile
        [[4, "desc"]]
      else [[6, "desc"]]

  dataTableParams = {
    aoColumns: aoColumns
    aaData: data
    aaSorting: sorting
    aLengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
    bDeferRender: true
    bProcessing: true
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
  }

  if clickTooltip 
    dataTableParams.iDisplayLength = 10
    dataTableParams.sScrollY = "260px"
  else if entity is "countries"
    dataTableParams.iDisplayLength = -1
  else
    dataTableParams.iDisplayLength = 100

  if mobile
    dataTableParams.iDisplayLength = 10
    dataTableParams.sDom = "Rrtip"

  oTable = $("#ranking").dataTable(dataTableParams)
    

  $(window).bind "resize", ->
    oTable.fnAdjustColumnSizing()

  $(@find("select")).chosen()
  if mobile
    $("tr").addClass("nohover")
