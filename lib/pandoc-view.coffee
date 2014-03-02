{$, $$$, View} = require 'atom'
path = require 'path'
pandoc = require './pandoc-command'
Stream = require 'stream'

module.exports =
class PandocView extends View
  atom.deserializers.add(this)

  @deserialize: ({filePath}) ->
    new PandocView(filepath)

  @content: ->
    @div class: 'pandoc-preview native-key-bindings', tabindex: -1

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

  frame: (html) ->
    @html $$$ ->
      @iframe src: "data:text/html, #{encodeURIComponent html}"

  render: ->
    text = @editor.getText()
    return if @lastText == text

    done = (d) =>
      @frame d
      @lastText = text
    err = (d) => @showError d
    from = @editor.getGrammar().name

    pandoc @getTextStream(text), {from, done, err}
