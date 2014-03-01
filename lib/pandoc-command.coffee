childProcess = require 'child_process'

module.exports = (inputStream, done, err) ->
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
  inputStream.pipe pandoc.stdin
