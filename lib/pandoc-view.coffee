{$, $$$, View} = require 'atom'
fs = require 'fs-plus'
pandoc = require './pandoc-command'
path = require 'path'
Stream = require 'stream'

module.exports =
class PandocView extends View
  atom.deserializers.add(this)

  @deserialize: ({filePath}) ->
    new PandocView(filepath)

  @content: ->
    @div class: 'pandoc-preview native-key-bindings', tabindex: -1, =>
      @iframe src: '/tmp/pandoc-preview'

  constructor: (editor) ->
    super
    @editor = editor
    @callback = setInterval (=> @render()), 1000

  # Returns an object that can be retrieved when package is activated
  serialize: ->
    deserializer: 'PandocView'
    filePath: @getPath()

  # Tear down any state and detach
  destroy: ->
    @unsubscribe()
    clearInterval @callback

  getTitle: ->
    "#{@editor.getTitle()} Preview"

  showError: (msg) ->
    @html $$$ ->
      @h2 'Previewing Failed'
      @h3 msg if msg?

  getTextStream: (text) ->
    input = new Stream.Readable()
    input.push text
    input.push null
    input

  reloadFrame: () ->
    @find('iframe')[0].contentWindow.location.reload()

  render: ->
    text = @editor.getText()
    return if @lastText == text

    out = fs.createWriteStream '/tmp/pandoc-preview'
    pandoc @getTextStream(text), out,
      from: @editor.getGrammar().name
      done: =>
        @reloadFrame()
        @lastText = text
      err: (d) =>
        @showError d
