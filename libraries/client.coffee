$ ->
  CHAT_HTML =
    '''
    <div style="position: fixed; right: 0; bottom: 0; width: 299px; border: 1px solid #A0A0A0">
     <ul id="soakoptics-messages" style="margin: 0; padding: 0; list-style-type: none"></ul>
     <div style="padding-left: 60px; background-color: white">
       <form id="soakoptics-send" style="margin-bottom: 0">
         <input id="soakoptics-message" type="text" placeholder="Your message" style="width: 180px" />
         <input type="submit" value="Send" />
       </form>
     </div>
    </div>
    '''
  
  socket = null
  
  messageHtml = (isMe, message) ->
    backgroundColor = if isMe then '#FFFFCC' else 'white'
    recipient = if isMe then 'me' else 'them'
    
    """
      <li style="border-bottom: 1px solid #F8F8F8; background-color: #{backgroundColor}">
        <div style="float: left; width: 50px; padding: 5px; text-align: right; border-right: 1px solid #E8E8E8">#{recipient}</div>
        <div style="padding: 5px 5px 5px 65px">#{message}</div>
      </li>
    """
    
  # inspired by: http://www.quirksmode.org/js/cookies.html
  createCookie = (name, value) ->
    document.cookie = "#{name}=#{value}; path=/"
  
  # inspired by: http://www.quirksmode.org/js/cookies.html
  readCookie = (name) ->
    name = "#{name}="
    cookies = document.cookie.split(';')
    for cookie in cookies
      cookie = cookie.replace(/^ +/, '')
      if cookie.indexOf(name) == 0
        return cookie.substring(name.length, cookie.length)
    null

  getPageSource = ->
    doctype = ''
    if document.doctype?
      doctype = "<!DOCTYPE #{document.doctype.name}"
      if document.doctype.publicId? and document.doctype.publicId != ''
        doctype += " PUBLIC '#{document.doctype.publicId}'"
        if document.doctype.systemId? and document.doctype.systemId != ''
          doctype += " '#{document.doctype.systemId}'"
      doctype += '>'
    
    html = $('html').html()
    "#{doctype}<html>#{html}</html>"
  
  retrieveCookie = ->
    cookie = readCookie('soakoptics')
    unless cookie?
      cookie = parseInt(Math.random() * 10000)
      createCookie 'soakoptics', cookie
    cookie
  
  emitReady = ->
    [cookie, url, html] = [retrieveCookie(), window.location.href, getPageSource()]
    [viewportWidth, viewportHeight] = [$(window).width(), $(window).height()]
    [scrollLeft, scrollTop] = [$(window).scrollLeft(), $(window).scrollTop()]
    
    socket.emit 'ready', DOMAIN_ID, cookie, url, html, viewportWidth, viewportHeight, scrollLeft, scrollTop

  socket = io.connect('http://localhost:4219')  
  socket.on 'connect', ->
    $('body').append(CHAT_HTML)
    emitReady()
    
    # message send
    $('#soakoptics-send').submit ->
      message = $('#soakoptics-message').val()
      socket.emit 'message', message
      $('#soakoptics-message').val ''
      $('#soakoptics-messages').append messageHtml(true, message)
      false
  
  # on message
  socket.on 'message', (message) ->
    $('#soakoptics-messages').append messageHtml(false, message)
  
  # on scroll
  scrollTimer = null
  $(window).scroll ->
    if scrollTimer?
      clearTimeout scrollTimer
      scrollTimer = null
    scrollTimer = setTimeout ( ->
        [scrollLeft, scrollTop] = [$(window).scrollLeft(), $(window).scrollTop()]
        socket.emit 'scroll', scrollLeft, scrollTop
      ), 100
  
  # on resize
  resizeTimer = null
  $(window).resize ->
    if resizeTimer?
      clearTimeout resizeTimer
      resizeTimer = null
    resizeTimer = setTimeout ( ->
      [viewportWidth, viewportHeight] = [$(window).width(), $(window).height()]
      socket.emit 'resize', viewportWidth, viewportHeight
    ), 100
