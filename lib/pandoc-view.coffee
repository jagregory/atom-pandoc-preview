{$, $$$, View} = require 'atom'
fs = require 'fs-plus'
pandoc = require './pandoc-command'
path = require 'path'
Stream = require 'stream'
Crypto = require 'crypto'
pdfjs = require './pdf'
pdfjsworker = require './pdf.worker'

module.exports =
class PandocView extends View
  atom.deserializers.add(this)

  @deserialize: ({filePath}) ->
    new PandocView(filepath)

  @content: ->
    @div class: 'pandoc-preview native-key-bindings', tabindex: -1, =>
      @iframe src: ''

  constructor: (editor) ->
    super
    @editor = editor
    @filename = @generateTempFilename editor
    @callback = setInterval (=> @render()), 1000

  generateTempFilename: (editor) ->
    p = editor.getPath()
    hash = Crypto.createHash('md5')
    hash.update if p? then path.basename(p) else editor.id
    "/tmp/#{hash.digest('hex')}.preview"

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
    frame = @find('iframe')
    if frame.attr('src') == @filename
      frame[0].contentWindow.location.reload()
    else
      frame.attr('src', @filename)

  render: ->
    text = @editor.getText()
    return if @lastText == text

    out = fs.createWriteStream @filename
    pandoc @getTextStream(text), out,
      from: @editor.getGrammar().name
      done: =>
        @reloadFrame()
        @lastText = text
      err: (d) =>
        @showError d
