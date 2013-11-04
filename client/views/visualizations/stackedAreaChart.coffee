# Color keys for domains, countries, and languages (if needed)
# Green, red, brown, yellow, beige, pink, blue, orange
color_domains = d3.scale.ordinal().domain(["INSTITUTIONS", "ARTS", "HUMANITIES", "BUSINESS & LAW", "EXPLORATION", "PUBLIC FIGURE", "SCIENCE & TECHNOLOGY", "SPORTS"]).range(["#468966", "#8e2800", "#864926", "#ffb038", "#fff0a5", "#bc4d96", "#1be6ef", "#ff5800"])
color_languages = d3.scale.ordinal().domain(["Afro-Asiatic", "Altaic", "Austro-Asiatic", "Austronesian", "Basque", "Caucasian", "Creoles and pidgins", "Dravidian", "Eskimo-Aleut", "Indo-European", "Niger-Kordofanian", "North American Indian", "Sino-Tibetan", "South American Indian", "Tai", "Uralic"]).range(["#E0BA9B", "#D95B43", "#43c1d9", "#C02942", "#546c97", "#d278c2", "#53a9f1", "#79BD9A", "#A69E80", "#ECD078", "#D28574", "#E7EDEA", "#CEECEF", "#912D1D", "#DE7838", "#59AB6D"])
color_countries = d3.scale.ordinal().domain(["Africa", "Asia", "Europe", "North America", "South America", "Oceania"]).range(["#E0BA9B", "#D95B43", "#43c1d9", "#C02942", "#546c97", "#d278c2"])

chartProps =
  width: 700
  height: 560

Template.stacked_svg.properties = chartProps

Template.stacked_svg.rendered = ->
  console.log("rendering STACKED AREA CHART")
  context = this

  d3.json "/partido.json", (partido) ->
    d3.json "/candidatura.json", (attr) ->
      d3.json "/pontuacao.json", (data) ->
        attrs = {}
        attr.candidaturas.forEach (a) ->
          a.candidatura = a.id
          partido.partidos.forEach (p) ->
            a.partidoNome = p.name_pt  if p.id is a.partido

          attrs[a.id] = a

        viz = d3plus.viz()
          .type("stacked")
          .id_var("candidatura")
          .attrs(attrs)
          .text_var("partidoNome")
          .value_var("pontos")
          .tooltip_info(["candidatura", "name_pt", "partido", "partidoNome", "politico", "pontos", "rodada"])
          .nesting(["partido", "candidatura"])
          .depth("partido")
          .xaxis_var("rodada")
          .year_var("rodada")
          .font("Helvetica Neue")
          .font_weight("lighter")
          .title("Test")
          .stack_type("monotone")
          .layout("value")
          .width($(".page-middle").width())
          .height("564")

        d3.select("#viz")
          .datum(data.pontuacoes)
          .call(viz)
