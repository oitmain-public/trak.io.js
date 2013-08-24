define ['exceptions','json2','lodash'], (Exceptions, JSON, _) ->

  class JSONP

    count: 0

    call: (endpoint, params, callback) ->
      this.jsonp(this.url(endpoint, params), callback)

    url: (endpoint, params) ->
      trak.io.protocol()+trak.io.host()+'/'+endpoint+this.params(endpoint, params)

    params: (endpoint, provided_params) ->
      params = this.default_params(endpoint)
      _.merge params, provided_params, (a, b) ->
        if _.isArray(a)
          _.uniq(a.concat(b))
        else
          undefined

      as_array = []
      for k of params
        v = params[k]
        v = JSON.stringify v if _.isArray(v) || _.isObject(v)
        as_array.push k+'='+encodeURIComponent(v)

      '?' + as_array.join('&')

    default_params: (endpoint) ->
      switch endpoint
        when 'identify'
          { token: trak.io.api_token(), data: { distinct_id: trak.io.distinct_id(), properties: {} } }
        when 'alias'
          { token: trak.io.api_token(), data: { distinct_id: trak.io.distinct_id() } }
        when 'track'
          { token: trak.io.api_token(), data: { distinct_id: trak.io.distinct_id(), properties: {}, channel: trak.io.channel(), context: trak.io.context() } }
        else
          {}


    callback: (data, callback) ->
      if data and data.status and data.status == 'success'
        callback data if callback
      else if data.exception and exception_class = Exceptions[data.exception.match(/\:\:([a-zA-Z0-9]+)$/)[1]]
        throw new exception_class(data.message, data.code, data.details, data)
      else
        throw new Exceptions.Unknown(data.message, data.code, data.details, data)

    noop: () ->
      # Nothing

    jsonp: (url, callback) ->

      timeout = 10000
      target = document.getElementsByTagName('script')[0]
      script
      timer

      # generate a unique id for this request
      id = this.count++
      me = this

      if timeout
        timer = setTimeout ->
          cleanup()
          me.callback({ status: 'error', exception: 'TrakioAPI::Exceptions::Timeout', message: "The server failed to respond in time."})
        , timeout

      cleanup = ->
        script.parentNode.removeChild script
        window['__trak' + id] = this.noop

      me = this
      window['__trak' + id] = (data) ->
        clearTimeout timer if timer
        cleanup()
        me.callback data, callback

      # add qs component
      url += (if ~url.indexOf('?') then '&' else '?') + 'callback=' + encodeURIComponent('__trak' + id + '');
      url = url.replace('?&', '?');


      # create script
      script = document.createElement 'script'
      script.src = url
      target.parentNode.insertBefore script, target

