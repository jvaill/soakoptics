{log} = require('util')
fs = require('fs')

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

log 'initializing'
init()

# start the servers
log 'starting client server'
clientServer = require('./client_server')
log 'starting admin server'
adminServer = require('./admin_server')

# the servers require references to eachother's clients
clientServer.admins = adminServer.admins
adminServer.clients = clientServer.clients
