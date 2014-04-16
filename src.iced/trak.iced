define ['jsonp','exceptions','io-query','cookie','lodash'], (JSONP,Exceptions,ioQuery,cookie,_) ->

  class Trak

    loaded: true
    Exceptions: Exceptions
    cookie: cookie

    constructor: ->
      this.io = this

    initialize: (@_api_token, options = {}) ->
      this.protocol(options.protocol)
      this.host(options.host) if options.host
      this.context(options.context) if options.context
      this.channel(options.channel) if options.channel
      this.distinct_id(options.distinct_id || null)
      this.root_domain(options.root_domain || null)

      if options.automagic
        this.load_automagic(options.automagic) unless this.automagic
      else
        this.automagic(false)

      me = this
      if options.auto_track_page_views != false
        this.page_ready ->
          me.page_view()

      this


    initialise: ()->
      this.initialize.apply this, arguments


    automagic: false
    load_automagic: (options = { minified: false }) ->

      script = document.createElement('script')

      if options.minified
        script.src = '/trak.automagic.min.js'
      else
        script.src = '/trak.automagic.js'


      me = this
      script.onload = ->
        me.automagic(new Automagic)
        me.automagic().initialize(options)

      document.head.insertBefore(script, document.head.firstChild)


    page_ready_event_fired: false
    page_ready: (fn) ->

      me = this
      # Create an idempotent version of the 'fn' function
      idempotent_fn = ->
        return  if me.page_ready_event_fired
        me.page_ready_event_fired = true
        fn()


      # The DOM ready check for Internet Explorer
      do_scroll_check = ->
        return  if @page_ready_event_fired

        # If IE is used, use the trick by Diego Perini
        # http://javascript.nwbox.com/IEContentLoaded/
        try
          document.documentElement.doScroll "left"
        catch e
          setTimeout do_scroll_check, 1
          return

        # Execute any waiting functions
        idempotent_fn()


      # If the browser ready event has already occured
      return idempotent_fn()  if document.readyState is "complete"

      # Mozilla, Opera and webkit nightlies currently support this event
      if document.addEventListener

        # Use the handy event callback
        document.addEventListener "DOMContentLoaded", idempotent_fn, false

        # A fallback to window.onload, that will always work
        window.addEventListener "load", idempotent_fn, false

      # If IE event model is used
      else if document.attachEvent

        # ensure firing before onload; maybe late but safe also for iframes
        document.attachEvent "onreadystatechange", idempotent_fn

        # A fallback to window.onload, that will always work
        window.attachEvent "onload", idempotent_fn

        # If IE and not a frame: continually check to see if the document is ready
        toplevel = false
        try
          toplevel = not window.frameElement?
        do_scroll_check()  if document.documentElement.doScroll and toplevel


    jsonp: new JSONP()

    call: () ->
      this.jsonp.call.apply this.jsonp, arguments


    identify: () ->

      me = this
      arguments[0] = arguments[0].toString() if typeof arguments[0] == 'number'
      args = this.sort_arguments(arguments, ['string', 'object', 'function'])
      distinct_id = args[0] || this.distinct_id()
      properties = args[1] || null
      callback = args[2] || null

      properties_length = 0
      properties_length++ for property,v of properties

      identify_call = (data) ->
        if properties
          me.call 'identify', { data: { distinct_id: distinct_id, properties: properties }}, callback
        else
          callback(data) if callback

      if args[0]
        me.alias(distinct_id, identify_call)

      else if properties && properties_length > 0
        identify_call()

      else if callback
        callback({status: 'unnecessary'})

      this


    alias: () ->
      arguments[0] = arguments[0].toString() if typeof arguments[0] == 'number'
      args = this.sort_arguments(arguments, ['string', 'string', 'boolean', 'function'])
      distinct_id = (if args[1] then args[0]) || this.distinct_id()
      alias = if args[1] then args[1] else args[0]
      update_distinct = if args[2] != null then args[2] else (if args[1] then false else true)
      callback = args[3] || null

      unless alias
        throw new Exceptions.MissingParameter('Missing a required parameter.', 400, 'You must provide an alias, see http://docs.trak.io/alias.html')
      if alias != distinct_id
        this.call 'alias', { data: { distinct_id: distinct_id, alias: alias }}, callback
        this.distinct_id(alias) if update_distinct
      else if callback
        callback({status: 'unnecessary'})

      this


    track: () ->
      args = this.sort_arguments(arguments, ['string', 'string', 'string', 'object', 'object', 'function'])
      distinct_id = (if args[2] then arguments[0]) || this.distinct_id()
      event = (if args[2] then args[1] else args[0])

      channel = (if args[2] then args[2] else args[1]) || this.channel()
      properties = args[3] || {}
      context = args[4] || {}
      context = _.merge this.context(), context
      callback = args[5] || null

      unless event
        throw new Exceptions.MissingParameter('Missing a required parameter.', 400, 'You must provide an event to track, see http://docs.trak.io/track.html')

      this.call 'track', { data: { distinct_id: distinct_id, event: event, channel: channel, context: context, properties: properties }}, callback

      this

    page_view: () ->
      args = this.sort_arguments(arguments, ['string', 'string', 'function'])
      url = args[0] || this.url()
      title = args[1] || this.page_title()
      callback = args[2] || null
      this.track 'page_view', { url: url, page_title: title }, callback
      this

    _protocol: 'https'
    protocol: (value)->
      this._protocol = value if value
      "#{this._protocol}://"

    _host: 'api.trak.io/v1'
    host: (value)->
      this._host = value if value
      this._host

    _automagic: false
    automagic: (value) ->
      this._automagic = value if value
      this._automagic

    _current_context: false
    current_context: (key, value)->

      unless this._current_context
        if c = this.get_cookie('context')
          this._current_context = JSON.parse(c)
        else
          this._current_context = {}

      if typeof key == 'object'
        _.merge this._current_context, key
      else if key and value
        this._current_context[key] = value

      this.set_cookie('context',JSON.stringify(this._current_context))
      this._current_context

    default_context: ->
      url = this.url()
      referer = this.referer()
      {
        ip: null
        user_agent: navigator.userAgent
        page_title: this.page_title()
        url: url
        params: if url.indexOf("?") > 0 then ioQuery.queryToObject(url.substring(url.indexOf("?") + 1, url.length)) else {}
        referer: referer
        referer_params: if referer.indexOf("?") > 0 then ioQuery.queryToObject(referer.substring(referer.indexOf("?") + 1, referer.length)) else {}
      }

    context: (key, value)->
      r = {}
      _.merge r, this.default_context(), this.current_context(key, value)
      r

    url: ->
      window.location.href

    referer: ->
      document.referrer

    page_title: ->
      document.title

    hostname: ->
      document.location.hostname

    url_params: ->
      window.location.search

    get_distinct_id_url_param: ->
      if (matches = @url_params().match /\?.*trak_distinct_id\=([^&]+).*/)
        decodeURIComponent(matches[1])


    _channel: false
    channel: (value)->
      if !this._channel and !(this._channel = this.get_cookie('channel'))
        this._channel = @hostname() || 'web_site'
      if value
        this._channel = value
        this.set_cookie('channel', value)
      this._channel

    _api_token: null
    api_token: ->
      this._api_token

    _distinct_id: null
    distinct_id: (value)->
      value = value.toString() if typeof value == 'number'
      if value
        this._distinct_id = value
      if !this._distinct_id and !(this._distinct_id = this.get_distinct_id_url_param()) and !(this._distinct_id = this.get_cookie('id'))
        this._distinct_id = this.generate_distinct_id()
      options = if @root_domain() == 'localhost' then {} else {domain: @root_domain()}
      cookie.set(this.cookie_key('id'), this._distinct_id, options)
      this._distinct_id

    generate_distinct_id: ->
      'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
          r = Math.random()*16|0
          v = if c == 'x' then r else (r&0x3|0x8)
          v.toString(16);

    _root_domain: null
    root_domain: (value) ->
      if !value && !@_root_domain
        @_root_domain = @get_root_domain()
      if value
        @_root_domain = value
      @_root_domain

    get_root_domain: () ->
      if @hostname().match(/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/i) || @hostname() == 'localhost'
        @hostname()
      else
        parts = @hostname().split('.')
        domain = parts.pop()
        while parts.length > 0
          break if @can_set_cookie({domain: domain})
          domain = "#{parts.pop()}.#{domain}"
        domain

    set_cookie: (key, value) ->
      cookie.set(this.cookie_key(key), value)

    get_cookie: (key)->
      cookie.get(this.cookie_key(key))

    can_set_cookie: (options) ->
      cookie.set(@cookie_key('foo'), '')
      cookie.set(@cookie_key('foo'), '', options)
      cookie.set(@cookie_key('foo'), 'bar', options)
      cookie.get(@cookie_key('foo')) == 'bar'


    cookie_key: (key)->
      "_trak_#{this.api_token()}_#{key}"

    sort_arguments: (values, types) ->
      values = Array.prototype.slice.call(values)
      r = []
      value = values.shift()
      for type in types
        if type == typeof value
          r.push value
          value = values.shift()
        else
          r.push null
      r

