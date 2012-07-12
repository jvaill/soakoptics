crypto = require('crypto')
path = require('path')
fs = require('fs')
cutiecapt = require('cutiecapt')
im = require('imagemagick')

cutiecapt.path = './bin/CutyCapt'

class Client
  constructor: (@socket, @siteId, @clientId, @url, @html, @viewportWidth, @viewportHeight, @scrollLeft, @scrollTop) ->
  ready: (@socket, @url, @html, @viewportWidth, @viewportHeight, @scrollLeft, @scrollTop) ->
  
  filePaths: (type) =>
    throw new Error('html must be set') unless @html?
    return @_filePaths if @_filePaths? and @_lastHtml == @html
    
    # ensure we don't generate duplicates by having a checksum as the filename
    md5 = crypto.createHash('md5').update(@html).digest('hex')
    # also include the viewport's resolution (if available) when dealing with images
    pngFilename = "#{md5}.png"
    pngFilename = "#{@viewportWidth}x#{@viewportHeight}-#{pngFilename}" if @viewportWidth? and @viewportHeight?
    
    # build the absolute paths
    htm = path.resolve("browsershots/html/#{md5}.htm")
    pngFull = path.resolve("browsershots/png-full/#{pngFilename}")
    pngThumb = path.resolve("browsershots/png-thumb/#{pngFilename}")
    
    @_lastHtml = @html
    @_filePaths =
      htm: htm
      pngFull: pngFull
      pngThumb: pngThumb
  
  captureFull: (cb) =>
    throw new Error('html must be set') unless @html?    
    filePaths = @filePaths()
    
    # write the .htm unless it already exists
    writeHtm = =>
      fs.exists filePaths.htm, (exists) =>
        unless exists
          fs.writeFile filePaths.htm, @html, (err) =>
            throw err if err
            capturePng()
        else
          capturePng()
    
    # capture the .png from the .htm
    capturePng = =>
      if @viewportWidth? and @viewportHeight?
        cutiecapt.options =
          minWidth: @viewportWidth
          minHeight: @viewportHeight
      else
        cutiecapt.options = {}
      
      cutiecapt.capture "file://#{filePaths.htm}", filePaths.pngFull, (err) =>
        throw err if err
        cb filePaths.pngFull
    
    # capture unless the .png already exists
    fs.exists filePaths.pngFull, (exists) =>
      unless exists
        writeHtm()
      else
        cb filePaths.pngFull
  
  captureThumb: (cb) =>
    THUMBNAIL_WIDTH = 256
    throw new Error('html must be set') unless @html?
    filePaths = @filePaths()
    
    # resize the full capture into a thumbnail
    resizeFull = (pngFull) =>
      im.resize srcPath: filePaths.pngFull, dstPath: filePaths.pngThumb, width: THUMBNAIL_WIDTH, (err) =>
        throw err if err
        cb filePaths.pngThumb
    
    # capture unless the .png already exists
    fs.exists filePaths.pngThumb, (exists) =>
      unless exists
        # first capture a full browser shot
        @captureFull => resizeFull()
      else
        cb filePaths.pngThumb
  
  capture: (cb) =>
    throw new Error('html must be set') unless @html?
    @captureFull => @captureThumb => cb(@filePaths())

module.exports = Client
