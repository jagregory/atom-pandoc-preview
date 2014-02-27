url = require 'url'
fs = require 'fs-plus'

PandocView = require './pandoc-view'

module.exports =
  activate: (state) ->
    cmd = 'pandoc'
    args = '-f markdown -t html5 -s -S --self-contained'
    atom.config.setDefaults('pandoc', {cmd, args})

    atom.workspaceView.command 'pandoc-preview:show', =>
      @show()

    atom.workspace.registerOpener (uri) ->
      {protocol, pathname} = url.parse uri
      return unless protocol is 'pandoc-preview:' and fs.isFileSync(pathname)
      new PandocView(pathname)

  show: ->
    editor = atom.workspace.getActiveEditor()
    return unless editor?
    previousActivePane = atom.workspace.getActivePane()
    atom.workspace.open("pandoc-preview://#{editor.getPath()}", split: 'right').done (view) ->
      view.render()
      previousActivePane.activate()
