fs = require('fs')
{log} = require('util')
Client = require('./client')
io = require('socket.io').listen(6294)

clients = {}

init = ->
  # create required directories
  directories = ['browsershots', 'browsershots/html', 'browsershots/png-full', 'browsershots/png-thumb']
  for directory in directories
    unless fs.existsSync(directory)
      log "creating directory #{directory}"
      fs.mkdirSync(directory)

init()

io.sockets.on 'connection', (socket) ->
  client = null
  
  socket.on 'ready', (siteId, clientId, url, html, viewportWidth, viewportHeight, scrollLeft, scrollTop) ->
    # create the in-memory site if it doesn't exists
    clients[siteId] = {} unless clients[siteId]?
    
    if clients[siteId][clientId]?
      # this is an existing client, retrieve it
      client = clients[siteId][clientId]
      client.ready socket, url, html, viewportWidth, viewportHeight, scrollLeft, scrollTop
    else
      # this is a new client, create it
      client = new Client(socket, siteId, clientId, url, html, viewportWidth, viewportHeight, scrollLeft, scrollTop)
      clients[siteId][clientId] = client
