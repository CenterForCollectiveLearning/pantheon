treeProps =
  width: 700
  height: 560

Template.treemap_svg.properties = treeProps

Template.treemap_svg.rendered = ->
  
  # Don't re-render with the same parameters...?
  context = this
  dataset = Session.get("dataset")
  viz = d3plus.viz()
  width = $(".page-middle").width()
  height = $(".page-middle").height() - 80
  Deps.autorun ->
    data = Treemap.find().fetch()
    attrs = {}
    vizMode = Session.get("vizMode")
    if vizMode is "country_exports" or vizMode is "country_imports" or vizMode is "bilateral_exporters_of"
      attr = Domains.find({dataset: dataset}).fetch()
      attr.forEach (a) ->
        dom = a.domain.capitalize()
        ind = a.industry.capitalize()
        occ = a.occupation.capitalize()
        dom_color = color_domains(dom.toUpperCase())
        domDict =
          id: dom
          name: dom
  
        indDict =
          id: ind
          name: ind
  
        occDict =
          id: occ
          name: occ
  
        attrs[dom] =
          id: dom
          name: dom
          color: dom_color
          nesting_1: domDict
  
        attrs[ind] =
          id: ind
          name: ind
          color: dom_color
          nesting_1: domDict
          nesting_3: indDict
  
        attrs[occ] =
          id: occ
          name: occ
          color: dom_color
          nesting_1: domDict
          nesting_3: indDict
          nesting_5: occDict
  
      flat = []
  
      data.forEach (d) ->
        flat.push #use a dummy year here for now ...
          id: d.occupation.capitalize()
          name: d.occupation.capitalize()
          num_ppl: d.count
          year: 2000
      
  
      viz.type("tree_map")
        .width(width)
        .height(height)
        .id_var("id")
        .attrs(attrs)
        .text_var("name")
        .value_var("num_ppl")
        .total_bar(
          prefix: "Total Exports: "
          suffix: " individuals"
        )
        .nesting(["nesting_1", "nesting_3", "nesting_5"]).depth("nesting_5").font("Lato").font_weight("300").color_var("color")
      d3.select(context.find("svg")).datum(flat).call viz
    else if vizMode is "domain_exports_to"
      attr = Countries.find({dataset:dataset}).fetch()
      attr.forEach (a) ->
        continent = a.continentName
        countryCode = a.countryCode
        countryName = a.countryName.capitalize()
        continent_color = color_countries(continent)
        continentDict =
          id: continent
          name: continent
  
        countryDict =
          id: countryCode
          name: countryName
  
        attrs[continent] =
          id: continent
          name: continent
          color: continent_color
          nesting_1: continentDict
  
        attrs[countryCode] =
          id: countryCode
          name: countryName
          color: continent_color
          nesting_1: continentDict
          nesting_3: countryDict
  
      flat = []
  
      data.forEach (d) ->
        flat.push #use a dummy year here for now ...
          id: d.countryCode
          name: d.countryName.capitalize()
          num_ppl: d.count
          year: 2000
  
      viz.type("tree_map")
          .width(width)
          .height(height)
          .id_var("id")
          .attrs(attrs)
          .text_var("name")
          .value_var("num_ppl")
          .total_bar(
            prefix: "Total Exports: "
            suffix: " individuals"
            )
          .nesting(["nesting_1", "nesting_3"])
          .depth("nesting_3")
          .font("Lato")
          .font_weight("300")
          .color_var("color")
      d3.select(context.find("svg")).datum(flat).call viz
    else if vizMode is "domain_imports_from" or vizMode is "bilateral_importers_of"
      attr = Languages.find().fetch()
      attr.forEach (a) ->
        family = a.lang_family
        langCode = a.lang
        langName = a.lang_name
        family_color = color_languages(family)
        familyDict =
          id: family
          name: family
  
        langDict =
          id: langCode
          name: langName
  
        attrs[family] =
          id: family
          name: family
          color: family_color
          nesting_1: familyDict
  
        attrs[langCode] =
          id: langCode
          name: langName
          color: family_color
          nesting_1: familyDict
          nesting_3: langDict
  
      flat = []
      data.forEach (d) ->
        flat.push #use a dummy year here for now ...
          id: d.lang
          name: d.lang_name
          num_ppl: d.count
          year: 2000
  
      viz.type("tree_map")
          .width(width)
          .height(height)
          .id_var("id")
          .attrs(attrs)
          .text_var("name")
          .value_var("num_ppl")
          .total_bar(
            prefix: "Total: "
            suffix: " Wikipedia Pages"
            )
          .nesting(["nesting_1", "nesting_3"])
          .depth("nesting_3")
          .font("Lato")
          .font_weight(400)
          .color_var("color")
  
      d3.select(context.find("svg"))
          .datum(flat)
          .call viz  