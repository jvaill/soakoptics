{log} = require('util')
Client = require('./client')
io = require('socket.io').listen(6294)

clients = {}
exports.clients = clients
exports.admins = null

emitAdmins = (siteId, params...) ->
  if exports.admins?[siteId]?
    for admin in exports.admins[siteId]
      admin.emit(params...) if admin.isConnected()

io.sockets.on 'connection', (socket) ->
  log 'client - connected'
  client = null
  
  socket.on 'ready', (siteId, clientId, url, html, viewportWidth, viewportHeight, scrollLeft, scrollTop) ->
    log 'client - ready'
    emitAdmins siteId, 'connected', clientId, url, viewportWidth, viewportHeight, scrollLeft, scrollTop
    
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
    
    client.capture (paths) =>
      emitAdmins siteId, 'captured', paths.pngFull, paths.pngThumb
  
  socket.on 'disconnect', ->
    log 'client - disconnect'
    emitAdmins client.siteId, 'disconnect', client.clientId
  
  socket.on 'scroll', (scrollLeft, scrollTop) ->
    log 'client - scroll'
    throw new Error('client null') unless client?
    client.scroll scrollLeft, scrollTop
    emitAdmins client.siteId, 'scroll', scrollLeft, scrollTop
  
  socket.on 'resize', (viewportWidth, viewportHeight) ->
    log 'client - resize'
    throw new Error('client null') unless client?
    client.resize viewportWidth, viewportHeight
    emitAdmins client.siteId, 'resize', viewportWidth, viewportHeight
  
  socket.on 'message', (message) ->
    log 'client - message'
    throw new Error('client null') unless client?
    client.message message
    emitAdmins client.siteId, 'message', message
