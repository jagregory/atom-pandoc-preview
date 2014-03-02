url = require 'url'
fs = require 'fs-plus'

PandocView = require './pandoc-view'

module.exports =
  activate: (state) ->
    @setConfigDefaults()

    atom.workspaceView.command 'pandoc-preview:show', =>
      @show()

  show: ->
    editor = atom.workspace.getActiveEditor()
    return unless editor?
    view = new PandocView(editor)
    pane = atom.workspace.getActivePane().splitRight()
    pane.addItem view
    view.render()

  setConfigDefaults: ->
    atom.config.setDefaults 'pandoc',
      cmd: 'pandoc'
      args: '-s -S --self-contained --ascii'
      languages:
        'github markdown': 'markdown'
        'html': 'html5'
        'markdown': 'markdown'
        'latex': 'latex'
