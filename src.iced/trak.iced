define 'Trak', ['jsonp','exceptions','io-query','cookie','lodash'], (JSONP,Exceptions,ioQuery,cookie,_) ->

  class Trak

    loaded: true
    Exceptions: Exceptions
    cookie: cookie
    minified: false

    @instances: []

    constructor: ->
      @io = @

    initialize: (@_api_token, @options = {}) =>
      @protocol(@options.protocol)
      @host(@options.host) if @options.host
      @context(@options.context) if @options.context
      @channel(@options.channel) if @options.channel
      @alias_on_identify(@options.alias_on_identify) if typeof @options.alias_on_identify != 'undefined'
      @distinct_id(@options.distinct_id || null)
      @company_id(@options.company_id || null)
      @root_domain(@options.root_domain || null)
      @page_ready_event_fired = false

      if @options.automagic
        @load_automagic(@options.automagic) unless @automagic
      else
        @automagic = false

      me = @

      @on_page_ready @page_ready

      Trak.instances.push @
      @


    initialise: ()=>
      @initialize.apply @, arguments


    load_automagic: (options) =>
      @automagic_options = options
      script = document.createElement('script')
      host = options.host || 'd29p64779x43zo.cloudfront.net/v1'
      if @minified
        script_src = 'trak.io.automagic.min.js'
      else
        script_src = 'trak.io.automagic.js'

      script.src = "//#{host}/#{script_src}"
      me = @

      head = document.head || document.getElementsByTagName("head")[0]
      head.insertBefore(script, head.firstChild)


    loaded_automagic: =>
      @automagic = new Trak.Automagic

      @automagic_options.test_hooks[0] @automagic if @automagic_options && @automagic_options.test_hooks && @automagic_options.test_hooks[0]
      @automagic.initialize(@automagic_options)
      @automagic_options.test_hooks[1] @automagic if @automagic_options && @automagic_options.test_hooks && @automagic_options.test_hooks[1]


    page_ready: ()=>
      if @options.auto_track_page_views != false
        @page_view()
      if @automagic
        @automagic.page_ready()

    page_ready_event_fired: false
    on_page_ready: (fn) =>
      me = @
      # Create an idempotent version of the 'fn' function
      idempotent_fn = ->
        return if me.page_ready_event_fired
        fn()
        me.page_ready_event_fired = true


      # The DOM ready check for Internet Explorer
      do_oll_check = ->
        return  if @page_ready_event_fired

        # If IE is used, use the trick by Diego Perini
        # http://javaipt.nwbox.com/IEContentLoaded/
        try
          document.documentElement.doScroll "left"
        catch e
          setTimeout do_oll_check, 1
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
        do_oll_check()  if document.documentElement.doScroll and toplevel


    jsonp: new JSONP()

    call: () =>
      @jsonp.call.apply @jsonp, arguments


    identify: () =>
      me = this
      arguments[0] = arguments[0].toString() if typeof arguments[0] == 'number'
      args = @sort_arguments(arguments, ['string', 'object', 'function'])
      distinct_id = args[0] || @distinct_id()
      properties = @proccess_companies(args[1]) || null
      callback = args[2] || null
      @should_track(true)

      properties_length = 0
      properties_length++ for property,v of properties

      identify_call = (data) ->
        if properties
          me.call 'identify', { data: { distinct_id: distinct_id, properties: properties }}, callback
        else
          callback(data) if callback

      if args[0] && @alias_on_identify()
        me.alias(distinct_id, identify_call)

      else if properties && properties_length > 0
        identify_call()

      else if callback
        callback({status: 'unnecessary'})

      this

    proccess_companies: (properties)->
      return null unless properties

      # String company should be moved to company_name
      if typeof properties.company == 'string'
        properties.company_name = properties.company
        delete properties.company

      # Company must be an array
      properties.company ||= []
      unless properties.company instanceof Array
        properties.company = [properties.company]
      properties.companies ||= []
      unless properties.companies instanceof Array
        properties.companies = [properties.companies]

      # Merge companies and company
      properties.company = properties.company.concat(properties.companies)
      delete properties.companies

      # Inject current company
      if @company_id()
        has = false
        for company in properties.company
          has = true if company.company_id == @company_id()
        if has
          properties.company <<
            company_id: @company_id()

      # Clean up company
      delete properties.company if properties.company.length == 0

      properties



    company: ()=>
      arguments[0] = arguments[0].toString() if typeof arguments[0] == 'number'
      args = @sort_arguments(arguments, ['string', 'object', 'function'])
      company_id = args[0] || @company_id()
      distinct_id = @distinct_id()
      properties = args[1] || null
      callback = args[2] || null

      properties_length = 0
      properties_length++ for property,v of properties

      if company_id
        @company_id(company_id)
      else
        throw new Exceptions.MissingParameter('Missing a required parameter.', 400, 'You must provide an `company_id`, see http://docs.trak.io/company.html')

      data =
        company_id: company_id
      data.properties = properties if properties && properties_length > 0
      data.people_distinct_ids = [distinct_id] if distinct_id && @should_track()

      if (properties && properties_length > 0) || (distinct_id && @should_track())
        @call 'company', { data: data }, callback
      else if callback
        callback { status: 'unnecessary' }

      this


    alias: () =>
      arguments[0] = arguments[0].toString() if typeof arguments[0] == 'number'
      args = @sort_arguments(arguments, ['string', 'string', 'boolean', 'function'])
      distinct_id = (if args[1] then args[0]) || @distinct_id()
      alias = if args[1] then args[1] else args[0]
      update_distinct = if args[2] != null then args[2] else (if args[1] then false else true)
      callback = args[3] || null

      unless alias
        throw new Exceptions.MissingParameter('Missing a required parameter.', 400, 'You must provide an alias, see http://docs.trak.io/alias.html')
      if alias != distinct_id
        @call 'alias', { data: { distinct_id: distinct_id, alias: alias }}, callback
        @distinct_id(alias) if update_distinct
      else if callback
        callback({status: 'unnecessary'})

      this


    track: () =>
      args = @sort_arguments(arguments, ['string', 'string', 'string','string', 'object', 'object', 'function'])
      distinct_id = (if args[2] then arguments[0]) || @distinct_id()
      distinct_id = null if arguments[0] == false
      company_id = (if args[3] then arguments[1]) || @company_id()
      company_id = null if arguments[1] == false
      if args[2] then arg_offset = 1 else arg_offset = 0
      if args[3] then arg_offset += 1
      event = args[0+arg_offset]
      channel = args[1+arg_offset] || @channel()
      properties = args[4] || {}
      context = args[5] || {}
      context = _.merge @context(), context
      callback = args[6] || null
      # debugger
      unless event
        throw new Exceptions.MissingParameter('Missing a required parameter.', 400, 'You must provide an event to track, see http://docs.trak.io/track.html')
      unless company_id || distinct_id
        throw new Exceptions.MissingParameter('Missing a required parameter.', 400, 'You must provide either a distinct_id and/or a company_id to track the event against, see http://docs.trak.io/track.html')

      data =
        event: event
        channel: channel
        context: context
        properties: properties

      data.distinct_id = distinct_id if distinct_id
      data.company_id = company_id if company_id

      if @should_track()
        @call 'track', { data: data }, callback

      this

    page_view: () =>
      args = @sort_arguments(arguments, ['string', 'string', 'function'])
      url = args[0] || @url()
      title = args[1] || @page_title()
      callback = args[2] || null
      @track 'page_view', { url: url, page_title: title }, callback
      this

    _protocol: 'https'
    protocol: (value) =>
      @_protocol = value if value
      "#{@_protocol}://"

    _host: 'api.trak.io/v1'
    host: (value) =>
      @_host = value if value
      @_host

    _current_context: false
    current_context: (key, value) =>

      unless @_current_context
        if c = @get_cookie('context')
          @_current_context = JSON.parse(c)
        else
          @_current_context = {}

      if typeof key == 'object'
        _.merge @_current_context, key
      else if key and value
        @_current_context[key] = value

      @set_cookie('context',JSON.stringify(@_current_context))
      @_current_context

    default_context: =>
      url = @url()
      referer = @referer()
      {
        ip: null
        user_agent: navigator.userAgent
        page_title: @page_title()
        url: url
        params: if url.indexOf("?") > 0 then ioQuery.queryToObject(url.substring(url.indexOf("?") + 1, url.length)) else {}
        referer: referer
        referer_params: if referer.indexOf("?") > 0 then ioQuery.queryToObject(referer.substring(referer.indexOf("?") + 1, referer.length)) else {}
      }

    context: (key, value) =>
      r = {}
      _.merge r, @default_context(), @current_context(key, value)
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

    get_company_id_url_param: ->
      if (matches = @url_params().match /\?.*trak_company_id\=([^&]+).*/)
        decodeURIComponent(matches[1])

    _channel: false
    channel: (value)->
      if !@_channel and !(@_channel = @get_cookie('channel'))
        @_channel = @hostname() || 'web_site'
      if value
        @_channel = value
        @set_cookie('channel', value)
      @_channel

    _should_track: null
    should_track: (value)->
      if @_should_track == null
        @_should_track = (@get_cookie('should_track') == 'true')
      if typeof value != 'undefined'
        @_should_track = value
        @set_cookie('should_track', value)
      @_should_track

    _alias_on_identify: true
    alias_on_identify: (value)->
      if typeof value != 'undefined'
        @_alias_on_identify = value
      @_alias_on_identify

    _api_token: null
    api_token: ->
      @_api_token

    _distinct_id: null
    distinct_id: (value)->
      value = value.toString() if typeof value == 'number'
      if value
        @_distinct_id = value
        @should_track(true)
      if !@_distinct_id and !(@_distinct_id = @get_distinct_id_url_param()) and !(@_distinct_id = @get_cookie('id'))
        @_distinct_id = @generate_distinct_id()
      options = if @root_domain() == 'localhost' then {} else {domain: @root_domain()}
      cookie.set(@cookie_key('id'), @_distinct_id, options)
      @_distinct_id

    _company_id: null
    company_id: (value)->
      value = value.toString() if typeof value == 'number'
      if value
        @_company_id = value

      if !@_company_id
        if !(@_company_id = @get_company_id_url_param())
          @_company_id = @get_cookie('company_id')

      options = if @root_domain() == 'localhost' then {} else { domain: @root_domain() }
      cookie.set(@cookie_key('company_id'), @_company_id, options) if @_company_id
      @_company_id

    unset_company_id: ()->
      @_company_id = null
      cookie.set(@cookie_key('company_id'), '0', {expires: -1})

    generate_distinct_id: ->
      'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
          r = Math.random()*16|0
          v = if c == 'x' then r else (r&0x3|0x8)
          v.toString(16);

    sign_out: ->
      @distinct_id(@generate_distinct_id())
      @unset_company_id()

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
      cookie.set(@cookie_key(key), value)

    get_cookie: (key)->
      cookie.get(@cookie_key(key))

    can_set_cookie: (options) ->
      cookie.set(@cookie_key('foo'), '')
      cookie.set(@cookie_key('foo'), '', options)
      cookie.set(@cookie_key('foo'), 'bar', options)
      cookie.get(@cookie_key('foo')) == 'bar'

    cookie_key: (key)->
      "_trak_#{@api_token()}_#{key}"

    sort_arguments: (values, types) ->
      values = Array.prototype.slice.call(values)
      r = []
      value = values.shift()
      for type in types
        if type == typeof value || value == null
          r.push value
          value = values.shift()
        else
          r.push null
      r


    debug_error: (error) ->
      if console && console.error
        if error.stack
          console.error error.stack
        else
          console.error error
