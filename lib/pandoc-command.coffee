childProcess = require 'child_process'
_ = require 'underscore-plus'

language = (name) ->
  (atom.config.get('pandoc.languages') || {})[name.toLowerCase()] || 'markdown'

args = (from) ->
  _.flatten ["-f #{language from} -t html5", atom.config.get('pandoc.args')]

module.exports = (inputStream, {from, done, err}) ->
  cmd = atom.config.get 'pandoc.cmd'
  cwd = atom.project.path

  stdout = ''
  stderr = ''
  pandoc = childProcess.spawn cmd, args(from), {cwd}
  pandoc.stdout.on 'data', (d) -> stdout += d.toString()
  pandoc.stderr.on 'data', (d) -> stderr += d.toString()
  pandoc.on 'close', ->
    if stderr == ''
      done stdout
    else
      err stderr
  inputStream.pipe pandoc.stdin
