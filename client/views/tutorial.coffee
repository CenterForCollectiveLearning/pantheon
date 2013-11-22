tutorialSteps = [
  template: Template.tutorial_step1
  onLoad: ->
    console.log "The tutorial has started!"
,
  template: Template.tutorial_step2
  spot: ".viz-selector"
]


Template.tutorial.options =
  steps: tutorialSteps
  onFinish: -> # make the tutorial disappear