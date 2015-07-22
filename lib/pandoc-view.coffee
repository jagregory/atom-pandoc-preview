_ = require 'underscore-plus'
{CompositeDisposable} = require 'atom'
{$, $$$, View} = require 'atom-space-pen-views'
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
    @disposables = new CompositeDisposable
    @editor = editor
    editor.onDidChange _.debounce((=> @render()), 400)

  # Returns an object that can be retrieved when package is activated
  serialize: ->
    deserializer: 'PandocView'
    filePath: @getPath()

  # Tear down any state and detach
  destroy: ->
    @disposables.dispose()

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
