crypto = require('crypto')
path = require('path')
fs = require('fs')
helpers = require('./helpers')
cutiecapt = require('cutiecapt')
im = require('imagemagick')

cutiecapt.path = './bin/CutyCapt'

class Client
  messages = []
  constructor: (@socket, @siteId, @id, @url, @html, @viewportWidth, @viewportHeight, @scrollLeft, @scrollTop) ->
  ready: (@socket, @url, @html, @viewportWidth, @viewportHeight, @scrollLeft, @scrollTop) ->
  scroll: (@scrollLeft, @scrollTop) ->
  resize: (@viewportWidth, @viewportHeight) ->
  message: (message) -> messages.push(message)
  isConnected: -> @socket?
  emit: (params...) -> @socket.emit(params...) if @isConnected()
  
  filePaths: (type) =>
    throw new Error('html must be set') unless @html?
    return helpers.clone(@_filePaths) if @_filePaths? and @_lastHtml == @html
    
    # ensure we don't generate duplicates by having a checksum as the filename
    md5 = crypto.createHash('md5').update(@html).digest('hex')
    # also include the viewport's resolution (if available) when dealing with images
    pngFilename = "#{md5}.png"
    pngFilename = "#{@viewportWidth}x#{@viewportHeight}-#{pngFilename}" if @viewportWidth? and @viewportHeight?
    
    # build the absolute paths
    htm = path.resolve("browsershots/html/#{md5}.htm")
    pngFull = path.resolve("browsershots/png-full/#{pngFilename}")
    pngThumb = path.resolve("browsershots/png-thumb/#{pngFilename}")
    
    @_filePaths =
      htm: htm
      pngFull: pngFull
      pngThumb: pngThumb
    @_lastHtml = @html
    # return a clone as @_filePaths could change
    helpers.clone @_filePaths
  
  captureFull: (cb) =>
    # capture these parameters to prevent changes between callbacks
    [filePaths, html, viewportWidth, viewportHeight] = [@filePaths(), @html, @viewportWidth, @viewportHeight]
    throw new Error('html must be set') unless html?
    
    # write the .htm unless it already exists
    writeHtm = =>
      fs.exists filePaths.htm, (exists) =>
        unless exists
          fs.writeFile filePaths.htm, html, (err) =>
            throw err if err
            capturePng()
        else
          capturePng()
    
    # capture the .png from the .htm
    capturePng = =>
      if viewportWidth? and viewportHeight?
        cutiecapt.options =
          minWidth: viewportWidth
          minHeight: viewportHeight
      else
        cutiecapt.options = {}
      
      cutiecapt.capture "file://#{filePaths.htm}", filePaths.pngFull, (err) =>
        throw err if err
        cb? filePaths.pngFull
    
    # capture unless the .png already exists
    fs.exists filePaths.pngFull, (exists) =>
      unless exists
        writeHtm()
      else
        cb? filePaths.pngFull
  
  captureThumb: (cb) =>
    THUMBNAIL_WIDTH = 256
    throw new Error('html must be set') unless @html?
    filePaths = @filePaths()
    
    # resize the full capture into a thumbnail
    resizeFull = (pngFull) =>
      im.resize srcPath: filePaths.pngFull, dstPath: filePaths.pngThumb, width: THUMBNAIL_WIDTH, (err) =>
        throw err if err
        cb? filePaths.pngThumb
    
    # capture unless the .png already exists
    # use synchronous exists to prevent race conditions (e.g. @html changing before @captureFull() is called)
    unless fs.existsSync(filePaths.pngThumb) and fs.existsSync(filePaths.pngFull)
      # first capture a full browser shot
      @captureFull => resizeFull()
    else
      cb? filePaths.pngThumb
  
  capture: (cb) =>
    throw new Error('html must be set') unless @html?
    filePaths = @filePaths()
    # in this case it's okay to only call @captureThumb() as it calls @captureFull() anyway
    # doing @captureFull => @captureThumb => cb?(filePaths) might seem like a cleaner option
    # but then we'd run into race conditions with options possibly changing between calls
    @captureThumb => cb?(filePaths)

module.exports = Client
