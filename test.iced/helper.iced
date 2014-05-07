window.memoize = window.memoized = window.value = (variable) ->
  if variable
    variable
  else
    new Memoized()

Memoized = ()->

  r = ()->
    if typeof r.f == 'function'
      r.v ||= r.f()
    else
      r.v ||= r.f

  r.equals = (f, now=false)->
    r.f2 = f
    if now
      r.f = f
    else
      beforeEach ()->
        r.f = f
    afterEach ()->
      r.f = null
      r.v = null
    r

  r.equals_now = (f)->
    r.equals f, true

  r.as = r.equals

  r.call_now = ()->
    r.v = r.f2() if r.f2
    r

  r.equals_haml = (string, now = false)->
    r.equals(()->
      html = eval(Haml.compile(string))
      div = document.createElement 'div'
      div.setAttribute('class','memoized-html')
      div.innerHTML = html;
      document.body.appendChild(div)
      unless Memoized.cleanups_registered
        afterEach ()->
          for element in _.find('.memoized-html')
            element.parentNode.removeChild(element);
        Memoized.cleanups_registered = true
      div.children[0]
    , now)
    r

  r.as_haml = r.equals_haml

  r.equals_haml_now = (string)->
    r.equals_haml(string, true)
    r

  r.as_haml_now = r.equals_haml_now

  r


Memoized.cleanups_registered = false

window.MockEvent = (event, target, properties={}) ->
  properties['type'] = event
  properties['srcElement'] = target
  properties['currentTarget'] = target
  properties['target'] = target
  properties = _.fixEvent(properties)
  properties
