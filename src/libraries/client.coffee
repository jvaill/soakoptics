$ ->
  CHAT_HTML =
    '''
    <div style="position: fixed; right: 0; bottom: 0; width: 299px; border: 1px solid #A0A0A0">
     <ul id="soakoptics-messages" style="margin: 0; padding: 0; list-style-type: none"></ul>
     <div style="padding-left: 60px; background-color: white">
       <form id="soakoptics-send">
         <input id="soakoptics-message" type="text" placeholder="Your message" style="width: 180px" />
         <input type="submit" value="Send" />
       </form>
     </div>
    </div>
    '''
  
  socket = null
  
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
  
  socket = io.connect('http://localhost:4219')  
  socket.on 'connect', -> $('body').append(CHAT_HTML)
