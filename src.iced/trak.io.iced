define 'trak.io', ['Trak', 'lodash','cookie'], (Trak, _, cookie) ->

  unless window.trak && window.trak.loaded

    trak = new Trak()

    # Loop through the interim analytics queue and reapply the calls to their
    # proper analytics.js method.
    queue = window.trak
    window.trak = trak
    window.Trak = window.trak.Trak = Trak
    while queue and queue.length > 0
      item = queue.shift()
      method = item.shift()
      trak.io[method].apply(trak.io, item) if trak.io[method]

    cookie.defaults.expires = 3650;
    cookie.defaults.path = '/';
  window.trak
