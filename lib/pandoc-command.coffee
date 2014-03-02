childProcess = require 'child_process'
_ = require 'underscore-plus'

language = (name) ->
  (atom.config.get('pandoc.languages') || {})[name.toLowerCase()] || 'markdown'

args = (from) ->
  _.flatten ["-f #{language from} -t html5", atom.config.get('pandoc.args')]

module.exports = (inputStream, outputStream, {from, done, err}) ->
  cmd = atom.config.get 'pandoc.cmd'
  cwd = atom.project.path

  stderr = ''
  pandoc = childProcess.spawn cmd, args(from), {cwd}
  pandoc.stderr.on 'data', (d) -> stderr += d.toString()
  pandoc.on 'close', ->
    if stderr == ''
      done()
    else
      err stderr
  pandoc.stdout.pipe outputStream
  inputStream.pipe pandoc.stdin
