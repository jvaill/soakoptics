{log} = require('util')
helpers = require('./helpers')
Admin = require('./admin')
io = require('socket.io').listen(7543)

admins = {}
exports.admins = admins
exports.clients = null

clientsInSite = (siteId, cb) ->
  if exports.clients?[siteId]?
    for id, client of exports.clients[siteId]
      console.log client
      cb?(client) if client.isConnected()

io.sockets.on 'connection', (socket) ->
  log 'admin - connected'
  admin = null
  
  socket.on 'ready', (siteId) ->
    log 'admin - ready'
    # create the in-memory site if it doesn't exists
    admins[siteId] = [] unless admins[siteId]?
    # create the admin
    admin = new Admin(socket, siteId)
    admins[siteId].push admin
    
    # load existing clients
    clientsInSite admin.siteId, (client) ->
      socket.emit 'connected', client.id, client.url,
                  client.viewportWidth, client.viewportHeight, client.scrollLeft, client.scrollTop
      client.capture (paths) =>
        paths = helpers.absPathToRelative(paths)
        socket.emit 'capture', client.id, paths.pngFull, paths.pngThumb
  
  socket.on 'disconnect', ->
    log 'admin - disconnect'
    admin.socket = null if client?
  
  socket.on 'message', (clientId, message) ->
    log 'admin - message'
    throw new Error('admin null') unless admin
    clientsInSite admin.siteId, (client) ->
      if client.id == clientId
        client.emit 'message', message
