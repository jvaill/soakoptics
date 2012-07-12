fs = require('fs')

{print} = require('util')
{spawn} = require('child_process')

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
  coffee.on 'exit', (code) ->
    callback?() if code is 0

clean = ->
  directories = ['lib', 'browsershots/html', 'browsershots/png-full', 'browsershots/png-thumb']
  # clear directories of files
  for directory in directories
    if fs.existsSync(directory)
      files = fs.readdirSync(directory)
      fs.unlinkSync("#{directory}/#{file}") for file in files
  
  fs.rmdirSync 'lib' if fs.existsSync('lib')

task 'start', 'Run and watch src/ for changes', ->
  start()

task 'build', 'Build lib/ from src/', ->
  build()

task 'watch', 'Watch src/ for changes', ->
  build true

task 'clean', 'Clean lib/', ->
  clean()
