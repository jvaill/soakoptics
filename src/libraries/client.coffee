$ ->
  # inspired by: http://www.quirksmode.org/js/cookies.html
  createCookie = (name, value) ->
    document.cookie = "#{name}=#{value}; path=/"
    alert document.cookie
  
  # inspired by: http://www.quirksmode.org/js/cookies.html
  readCookie = (name) ->
    name = "#{name}="
    cookies = document.cookie.split(';')
    for cookie in cookies
      cookie = cookie.replace(/^ +/, '')
      if cookie.indexOf(name) == 0
        return cookie.substring(name.length, cookie.length)
    null
