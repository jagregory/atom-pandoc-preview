_ = require 'underscore-plus'
{$, $$$, View} = require 'atom'
pandoc = require './pandoc-command'
path = require 'path'
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
    @subscribe editor.buffer, 'changed', _.debounce((=> @render()), 400)

  # Returns an object that can be retrieved when package is activated
  serialize: ->
    deserializer: 'PandocView'
    filePath: @getPath()

  # Tear down any state and detach
  destroy: ->
    @unsubscribe()

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
    pandoc @getTextStream(@editor.getText()),
      from: @editor.getGrammar().name
      done: (d) => @frame d
      err: (d) => @showError d
