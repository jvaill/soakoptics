{print} = require('util')
{spawn} = require('child_process')
wrench = require('wrench')
fs = require('fs')

buildBrowserLibraries = (watch, callback) ->
  options = ['-c', '-o', 'public/libraries', 'src/libraries']
  options.unshift('-w') if watch
  coffee = spawn('coffee', options)
  
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    callback?() if code is 0

# move the browser libraries into public so they're accessible via http
moveBrowserLibraries = ->
  if fs.existsSync('lib/libraries')
    if fs.readdirSync('lib/libraries').length
      wrench.mkdirSyncRecursive('public/libraries') unless fs.existsSync('public/libraries')
      wrench.copyDirSyncRecursive 'lib/libraries', 'public/libraries'
    wrench.rmdirSyncRecursive 'lib/libraries'

start = ->
  nodemon = spawn('nodemon', ['--watch', 'src', 'src/main.coffee'])
  nodemon.stderr.on 'data', (data) ->
    if data.toString().match(/^execvp/)
      process.stderr.write "error starting nodemon, please ensure it is installed correctly\n"
      process.stderr.write "  npm install nodemon -g\n"
    process.stderr.write data.toString()
  nodemon.stdout.on 'data', (data) ->
    print data.toString()

build = (watch, callback) ->
  options = ['-c', '-o', 'lib', 'src']
  options.unshift('-w') if watch
  coffee = spawn('coffee', options)
  
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
    moveBrowserLibraries() if watch
  coffee.on 'exit', (code) ->
    moveBrowserLibraries() unless watch
    callback?() if code is 0

clean = ->
  wrench.rmdirSyncRecursive('lib') if fs.existsSync('lib')
  wrench.rmdirSyncRecursive('public') if fs.existsSync('public')

task 'start', 'Run and watch src/ for changes', ->
  buildBrowserLibraries true
  start()

task 'build', 'Build lib/ from src/', ->
  build()

task 'watch', 'Watch src/ for changes', ->
  build true

task 'clean', 'Clean lib/', ->
  clean()
