childProcess = require 'child_process'
_ = require 'underscore-plus'

languages =
  'github markdown': 'markdown'
  'html': 'html5'
  'markdown': 'markdown'
  'latex': 'latex'

language = (name) ->
  languages[name.toLowerCase()] || 'markdown'

args = (from) ->
  pandoc_args = "-f #{language from} -t html5" + ' ' + atom.config.get('pandoc.args')

  return _.compact(pandoc_args.replace(/(-[\S]+)\s*/gm, '\r\n$1\r\n').split('\r\n'))
    .map((s)-> s.trim().replace(/^("|')([\s\S]*?)\1$/g, '$2'))

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
