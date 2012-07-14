{log} = require('util')
fs = require('fs')
wrench = require('wrench')
path = require('path')
http = require('http')
paperboy = require('paperboy')

init = ->
  BROWSERSHOTS_PATH = 'public/browsershots'
  directories = [
    "#{BROWSERSHOTS_PATH}/html",
    "#{BROWSERSHOTS_PATH}/png-full",
    "#{BROWSERSHOTS_PATH}/png-thumb"
  ]
  
  # create required directories
  for directory in directories
    unless fs.existsSync(directory)
      log "creating directory #{directory}"
      wrench.mkdirSyncRecursive directory

startPaperboy = ->
  webroot = path.resolve('public')
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
