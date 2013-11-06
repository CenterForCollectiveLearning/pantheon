histogramProps = 
  width: 725
  height: 560

Template.histogram_svg.properties = histogramProps

Template.histogram_svg.rendered = ->
  context = this
  data = Histogram.find().fetch()