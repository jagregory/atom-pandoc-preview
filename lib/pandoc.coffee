url = require 'url'
fs = require 'fs-plus'

PandocView = require './pandoc-view'
{CompositeDisposable} = require 'atom'

module.exports =
  config:
    cmd:
      type: 'string'
      default: 'pandoc'
    args:
      type: 'string'
      default: '-s -S --self-contained --ascii'

  activate: (state) ->
    @disposables = new CompositeDisposable
    @disposables.add atom.commands.add 'atom-workspace', 'pandoc-preview:show', =>
      @show()

  deactivate: ->
    @disposables.dispose()

  show: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?
    view = new PandocView(editor)
    pane = atom.workspace.getActivePane().splitRight()
    pane.addItem view
    view.render()
