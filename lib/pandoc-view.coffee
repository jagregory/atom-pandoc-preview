path = require 'path'
{$, $$$, EditorView, ScrollView} = require 'atom'
fs = require 'fs'
childProcess = require 'child_process'

module.exports =
class PandocView extends ScrollView
  atom.deserializers.add(this)

  @deserialize: ({filePath}) ->
    new PandocView(filepath)

  @content: ->
    @div class: 'pandoc-preview native-key-bindings', tabindex: -1

  constructor: (filePath) ->
    super
    @filePath = filePath
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
    'meow'

  showError: (msg) ->
    @html $$$ ->
      @h2 'Previewing Failed'
      @h3 msg if msg?

  render: ->
    input = fs.createReadStream(@filePath)

    stdout = ''
    pandoc = childProcess.spawn('pandoc', ['-f', 'markdown', '-t', 'html5', '-s', '-S'])
    pandoc.stdout.on 'data', (data) =>
      stdout += data.toString()
    pandoc.stderr.on 'data', (data) =>
      @showError data.toString()
    pandoc.on 'close', =>
      @html stdout
    input.pipe pandoc.stdin
