url = require 'url'
fs = require 'fs-plus'

PandocView = require './pandoc-view'

module.exports =
  activate: (state) ->
    cmd = 'pandoc'
    args = '-s -S --self-contained'
    atom.config.setDefaults('pandoc', {cmd, args})

    atom.workspaceView.command 'pandoc-preview:show', =>
      @show()

  show: ->
    editor = atom.workspace.getActiveEditor()
    return unless editor?
    view = new PandocView(editor)
    pane = atom.workspace.getActivePane().splitRight()
    pane.addItem view
    view.render()
