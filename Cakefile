{print} = require('util')
{spawn} = require('child_process')
wrench = require('wrench')
fs = require('fs')

build = (source, dest, watch, callback) ->
  options = ['-c', '-o', dest, source]
  options.unshift('-w') if watch
  coffee = spawn('coffee', options)
  
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    callback?() if code is 0

start = ->
  nodemon = spawn('nodemon', ['--watch', 'src', 'src/main.coffee'])
  nodemon.stderr.on 'data', (data) ->
    if data.toString().match(/^execvp/)
      process.stderr.write "error starting nodemon, please ensure it is installed correctly\n"
      process.stderr.write "  npm install nodemon -g\n"
    process.stderr.write data.toString()
  nodemon.stdout.on 'data', (data) ->
    print data.toString()

clean = ->
  wrench.rmdirSyncRecursive('lib') if fs.existsSync('lib')
  wrench.rmdirSyncRecursive('public') if fs.existsSync('public')

task 'start', 'Run and watch src/ and /libraries for changes', ->
  build 'libraries', 'public/libraries', true
  start()

task 'build', 'Build src/ and libraries/', ->
  build 'libraries', 'public/libraries'
  build 'src', 'lib'

task 'watch', 'Watch src/ and libraries/ for changes', ->
  build 'libraries', 'public/libraries', true
  build 'src', 'lib', true

task 'clean', 'Clean lib/ and public/', ->
  clean()
