{$, $$$, ScrollView} = require 'atom'
path = require 'path'
pandoc = require './pandoc-command'
Stream = require 'stream'

module.exports =
class PandocView extends ScrollView
  atom.deserializers.add(this)

  @deserialize: ({filePath}) ->
    new PandocView(filepath)

  @content: ->
    @div class: 'pandoc-preview native-key-bindings', tabindex: -1

  constructor: (getText) ->
    super
    @getTextStream = ->
      input = new Stream.Readable()
      input.push getText()
      input.push null
      input
    @handleEvents()

  handleEvents: ->
    @subscribe this, 'core:move-up', => @scrollUp()
    @subscribe this, 'core:move-down', => @scrollDown()

  # Returns an object that can be retrieved when package is activated
  serialize: ->
    deserializer: 'PandocView'
    filePath: @getPath()

  # Tear down any state and detach
  destroy: ->
    @unsubscribe()

  getTitle: ->
    "#{path.basename @filePath} Preview"

  showError: (msg) ->
    @html $$$ ->
      @h2 'Previewing Failed'
      @h3 msg if msg?

  render: ->
    pandoc @getTextStream(),
      (d) => @html d,
      (d) => @showError d
