class Admin
  constructor: (@socket, @siteId) ->
  isConnected: -> @socket?
  emit: (params...) -> @socket.emit(params...) if @isConnected()

module.exports = Admin
