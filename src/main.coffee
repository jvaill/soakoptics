{log} = require('util')
fs = require('fs')
path = require('path')
http = require('http')
paperboy = require('paperboy')

init = ->
  directories = [
    'browsershots',
    'browsershots/html',
    'browsershots/png-full',
    'browsershots/png-thumb'
  ]
  
  # create required directories
  for directory in directories
    unless fs.existsSync(directory)
      log "creating directory #{directory}"
      fs.mkdirSync(directory)

startPaperboy = ->
  webroot = path.resolve('browsershots')
  server = http.createServer (req, res) ->
    paperboy.deliver webroot, req, res
  server.listen 2724

log 'initializing'
init()
log 'starting paperboy'
startPaperboy()

# start the servers
log 'starting client server'
clientServer = require('./client_server')
log 'starting admin server'
adminServer = require('./admin_server')

# the servers require references to eachother's clients
clientServer.admins = adminServer.admins
adminServer.clients = clientServer.clients
