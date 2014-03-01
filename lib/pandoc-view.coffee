path = require 'path'
{$, $$$, ScrollView} = require 'atom'
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
    "#{path.basename @filePath} Preview"

  showError: (msg) ->
    @html $$$ ->
      @h2 'Previewing Failed'
      @h3 msg if msg?

  pandoc: (path, done, err) ->
    cmd = atom.config.get 'pandoc.cmd'
    args = atom.config.get 'pandoc.args'
    cwd = atom.project.path

    stdout = ''
    stderr = ''
    pandoc = childProcess.spawn cmd, [args], {cwd}
    pandoc.stdout.on 'data', (d) -> stdout += d.toString()
    pandoc.stderr.on 'data', (d) -> stderr += d.toString()
    pandoc.on 'close', ->
      if stderr == ''
        done stdout
      else
        err stderr
    fs.createReadStream(path).pipe pandoc.stdin

  render: ->
    @pandoc @filePath,
      (d) => @html d,
      (d) => @showError d
