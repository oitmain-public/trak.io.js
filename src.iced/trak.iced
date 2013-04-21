define ['jsonp','exceptions','io-query','cookie','lodash'], (JSONP,Exceptions,ioQuery,cookie,_) ->

  class Trak

    constructor: ->
      this.io = this

    initialize: (@_api_token, options = {}) ->
      this.protocol(options.protocol)
      this.host(options.host) if options.host
      this.context(options.context) if options.context
      this.medium(options.medium) if options.medium
      this.distinct_id(options.distinct_id || null)

      if options.track_page_views != false
        this.page_view()


    initialise: ()->
      this.initialize.apply this, arguments


    jsonp: new JSONP()

    call: () ->
      this.jsonp.call.apply this.jsonp, arguments

    identify: (a1, a2) ->

      if _.isString(a1)
        distinct_id = a1
        properties = a2
        this.distinct_id(distinct_id)
      else
        properties = a1

      properties = {} unless properties
      distinct_id = this.distinct_id() unless distinct_id

      this.call 'identify', { distinct_id: distinct_id, data: { properties: properties }}
      null


    alias: (a1, a2) ->

      if _.isString(a1) and _.isString(a2)
        distinct_id = a1
        alias = a2
        update_distinct = false
      else if _.isString(a1) and _.isBoolean(a2)
        distinct_id = this.distinct_id()
        alias = a1
        update_distinct = false
      else
        distinct_id = this.distinct_id()
        alias = a1
        update_distinct = true

      unless alias
        throw new Exceptions.MissingParameter('Missing a required parameter.', 400, 'You must provide an alias, see http://docs.trak.io/alias.html')

      this.call 'alias', { data: { distinct_id: distinct_id, alias: alias }}
      this.distinct_id(alias) if update_distinct
      null

    track: (a1, a2, a3, a4, a5) ->

      if _.isString(a1) and (_.isObject(a2) || _.isUndefined(a2))
        event = a1
        properties = a2
        context = a3
      else if _.isString(a1) and _.isString(a2) and (_.isObject(a3) || _.isUndefined(a3))
        event = a1
        medium = a2
        properties = a3
        context = a4
      else if _.isString(a1) and _.isString(a2) and _.isString(a3)
        distinct_id = a1
        event = a2
        medium = a3
        properties = a4
        context = a5

      distinct_id = this.distinct_id() unless distinct_id
      context = {} unless context
      _.merge context, this.context()
      medium = this.medium() unless medium
      properties = {} unless properties

      unless event
        throw new Exceptions.MissingParameter('Missing a required parameter.', 400, 'You must provide an event to track, see http://docs.trak.io/track.html')

      this.call 'track', { data: { distinct_id: distinct_id, event: event, medium: medium, context: context, properties: properties }}
      null

    page_view: (url=this.url(), title=this.page_title()) ->
      this.track 'page_view', { url: url, page_title: title }

    _protocol: 'https'
    protocol: (value)->
      this._protocol = value if value
      "#{this._protocol}://"

    _host: 'api.trak.io'
    host: (value)->
      this._host = value if value
      this._host

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
      referrer = this.referrer()
      {
        ip: null
        user_agent: navigator.userAgent
        url: url
        params: if url.indexOf("?") > 0 then ioQuery.queryToObject(url.substring(url.indexOf("?") + 1, url.length)) else {}
        referrer: referrer
        referrer_params: if referrer.indexOf("?") > 0 then ioQuery.queryToObject(referrer.substring(referrer.indexOf("?") + 1, referrer.length)) else {}
      }

    context: (key, value)->
      r = {}
      _.merge r, this.default_context(), this.current_context(key, value)
      r

    url: ->
      window.location.href

    referrer: ->
      document.referrer

    page_title: ->
      document.title

    _medium: false
    medium: (value)->
      if !this._medium and !(this._medium = this.get_cookie('medium'))
        this._medium = 'web_site'
      if value
        this._medium = value
        this.set_cookie('medium', value)
      this._medium

    _api_token: null
    api_token: ->
      this._api_token

    _distinct_id: null
    distinct_id: (value)->
      if value
        this._distinct_id = value
      if !this._distinct_id and !(this._distinct_id = this.get_cookie('id'))
        this._distinct_id = this.generate_distinct_id()
      this.set_cookie('id', this._distinct_id)
      this._distinct_id

    generate_distinct_id: ->
      'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
          r = Math.random()*16|0
          v = if c == 'x' then r else (r&0x3|0x8)
          v.toString(16);

    set_cookie: (key, value) ->
      cookie.set(this.cookie_key(key), value)

    get_cookie: (key)->
      cookie.get(this.cookie_key(key))

    cookie_key: (key)->
      "_trak_#{this.api_token()}_#{key}"
