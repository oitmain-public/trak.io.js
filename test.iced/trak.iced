describe 'Trak', ->

  afterEach ->
    trak.cookie.empty() # Only empties for the current domain
    for key in trak.cookie.utils.getKeys(trak.cookie.all())
      trak.cookie.set key, 'a', { domain: '.lvh.me', expires: -1 }
    trak.cookie.set('_trak_null_id','b', {expires: -1})
    trak.io._protocol = 'https'
    trak.io._host = 'api.trak.io'
    trak.io._current_context = false
    trak.io._channel = false
    trak.io._distinct_id = null
    trak.io._root_domain = null


  describe '#initialize', ->

    it "stores api token", ->
      trak.io.initialize('api_token_value', { auto_track_page_views: false })
      trak.io.api_token().should.equal 'api_token_value'


    it "stores protocol option", ->
      trak.io.initialize('api_token_value', { protocol: 'http', auto_track_page_views: false })
      trak.io.protocol().should.equal 'http://'


    it "stores host option", ->
      trak.io.initialize('api_token_value', { host: 'custom_host.com', auto_track_page_views: false  })
      trak.io.host().should.equal 'custom_host.com'


    it "stores context option", ->
      trak.io.initialize('api_token_value', { context: { foo: 'bar' }, auto_track_page_views: false })
      trak.io.current_context().should.eql {foo: 'bar'}


    it "stores channel option", ->
      trak.io.initialize('api_token_value', { channel: 'custom_channel', auto_track_page_views: false })
      trak.io.channel().should.equal 'custom_channel'


    it "stores distinct_id option", ->
      trak.io.initialize('api_token_value', { distinct_id: 'custom_distinct_id', auto_track_page_views: false })
      trak.io.distinct_id().should.equal 'custom_distinct_id'


    it "stores root domain option", ->
      trak.io.initialize('api_token_value', { root_domain: 'root_domain.co.uk', auto_track_page_views: false })
      trak.io.root_domain().should.equal 'root_domain.co.uk'


    it "set up default options", ->
      trak = new Trak()
      sinon.stub(trak.io, 'get_root_domain').returns('.lvh.me')
      trak.io.initialize('api_token_value', { auto_track_page_views: false })
      trak.io.protocol().should.equal 'https://'
      trak.io.host().should.equal 'api.trak.io/v1'
      trak.io.get_root_domain().should.equal '.lvh.me'
      trak.io.current_context().should.eql {}
      trak.io.channel().should.equal window.location.hostname
      trak.io.get_root_domain.restore()


    it "calls #on_page_ready", ->
      sinon.stub(trak.io, 'on_page_ready')
      sinon.stub(trak.io, 'url').returns('page_url')
      sinon.stub(trak.io, 'page_title').returns('A page title')
      trak.io.initialize('api_token_value', { auto_track_page_views: false })
      trak.io.on_page_ready.should.have.been.calledWith trak.io.page_ready
      trak.io.on_page_ready.restore()
      trak.io.page_title.restore()
      trak.io.url.restore()


    it "should not set up automagic by default", ->
      trak.io.initialize('api_token_value', { auto_track_page_views: false })
      trak.io.automagic.should.equal false
      script_name = if document.location.pathname == '/test/trak.io.min.html' then 'trak.io.automagic.min.js' else 'trak.io.automagic.js'
      $("script[src='//#{document.location.host}/#{script_name}']").length.should.equal(0)


    it "should set up automagic if set to true", ->
      trak = new Trak()
      trak.io.initialize 'api_token_value',
        auto_track_page_views: false
        automagic: true
      script_name = if document.location.pathname == '/test/trak.io.min.html' then 'trak.io.automagic.min.js' else 'trak.io.automagic.js'
      script = $("script[src='//d29p64779x43zo.cloudfront.net/v1/#{script_name}']")
      script.length.should.equal(1)
      script.remove()


    it "should load automagic from specified host", (done) ->
      trak = new Trak()
      trak.io.initialize 'api_token_value',
        auto_track_page_views: false
        automagic:
          host: document.location.host
          test_hooks: [
            (automagic) ->
              automagic.initialize = sinon.spy()
            ,(automagic) ->
              automagic.initialize.should.have.been.called
              automagic.should.not.equal false
              done()
          ]
      script_name = if document.location.pathname == '/test/trak.io.min.html' then 'trak.io.automagic.min.js' else 'trak.io.automagic.js'
      script = $("script[src='//#{document.location.host}/#{script_name}']")
      script.length.should.equal(1)


  describe '#page_ready', ->

    it "doesn't call #page_view if auto_track_page_views is false", ->
      trak = new Trak()
      trak.io.initialize 'api_token_value',
        auto_track_page_views: false
      sinon.stub(trak.io, 'page_view')

      trak.io.page_ready()

      trak.io.page_view.should.not.have.been.called

      trak.io.page_view.restore()


  describe '#initialise', ->

    it "aliases #initialize", ->
      sinon.stub(trak.io, 'initialize')
      arg = 'a'
      trak.io.initialise(arg)
      trak.io.initialize.should.have.been.calledWith(arg)
      trak.io.initialize.restore()


  describe '#protocol', ->

    it "returns https by default", ->
      trak.io.protocol().should.equal 'https://'

    it "returns provided value plus :// if set", ->
      trak.io.protocol('http').should.equal 'http://'
      trak.io.protocol().should.equal 'http://'


  describe '#host', ->

    it "returns api.trak.io by default", ->
      trak.io.host().should.equal 'api.trak.io'

    it "allows value to be set", ->
      trak.io.host('custom.com').should.equal 'custom.com'
      trak.io.host().should.equal 'custom.com'


  describe '#call', ->

    it "calls .jsonp.call with arguments", ->
      jsonp_call = sinon.stub(trak.io.jsonp, 'call')
      argument1 = 'a'
      argument2 = 'b'
      trak.io.call(argument1, argument2)
      jsonp_call.should.have.been.calledWith(argument1,argument2)


  describe '#api_token', ->

    it "retuns provided api_token", ->
      trak.io.initialize 'my_api_token'
      trak.io.api_token().should.equal 'my_api_token'


  describe '#distinct_id', ->

    it "generates custom distinct_id if non provided", ->
      trak.io.distinct_id().should.match /[0-9a-f]{7}\-[0-9a-f]{4}-4[0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}/

    it "returns the provided value", ->
      trak.io.distinct_id('my_distinct_id').should.equal 'my_distinct_id'
      trak.io.distinct_id().should.equal 'my_distinct_id'

    it "sets value in cookie", ->
      trak.io.distinct_id('my_distinct_id')
      cookie.get("_trak_#{trak.io.api_token()}_id").should.equal 'my_distinct_id'

    it "gets distinct_id based on cookie", ->
      cookie.set("_trak_#{trak.io.api_token()}_id",'distinct_id_value2')
      trak.io.distinct_id().should.equal 'distinct_id_value2'

    it "gets distinct_id from url", ->
      sinon.stub(trak.io, 'url_params').returns('?a=a&trak_distinct_id=%7Basdfasdf%7D&b=b')
      trak.io.distinct_id().should.equal '{asdfasdf}'

    it "takes an numerical value for id", ->
      trak.io.distinct_id(1234)
      trak.io.distinct_id().should.eq('1234')


  describe '#context', ()->

    it "returns null ip by default, when we sent null to api.trak.io it will fill it in from request", ->
      expect(trak.io.context().ip).to.be.null

    it "returns user agent by default", ->
      trak.io.context().user_agent.should.equal(navigator.userAgent)

    it "returns current url by default", ->
      sinon.stub(trak.io, 'url').returns('http://example.com/?a=b&c=d')
      trak.io.context().url.should.equal('http://example.com/?a=b&c=d')
      trak.io.url.restore()

    it "returns params by default", ->
      sinon.stub(trak.io, 'url').returns('http://example.com/?a=b&c=d')
      trak.io.context().params.should.eql({a: 'b', c: 'd'})
      trak.io.url.restore()

    it "returns referer by default", ->
      sinon.stub(trak.io, 'referer').returns('http://referer.com/?a=b&c=d')
      trak.io.context().referer.should.equal('http://referer.com/?a=b&c=d')
      trak.io.referer.restore()

    it "returns referer params by default", ->
      sinon.stub(trak.io, 'referer').returns('http://referer.com/?a=b&c=d')
      trak.io.context().referer_params.should.eql({a: 'b', c: 'd'})
      trak.io.referer.restore()

    it "allows individual contexts to be set", ->
      trak.io.context('foo', 'bar').foo.should.equal 'bar'
      trak.io.context().foo.should.equal 'bar'

    it "allows contexts to be set", ->
      initial = trak.io.context({override: 'foo', keep: 'foo'})
      initial.override.should.equal 'foo'
      initial.keep.should.equal 'foo'
      added_to = trak.io.context({override: 'bar', add: 'bar'})
      added_to.override.should.equal 'bar'
      added_to.keep.should.equal 'foo'
      added_to.add.should.equal 'bar'

    it "merges provided with defaults", ->
      sinon.stub(trak.io, 'url').returns('http://example.com/?a=b&c=d')
      sinon.stub(trak.io, 'referer').returns('http://referer.com/?a=b&c=d')
      title = if document.location.pathname == '/test/trak.io.min.html' then 'Tests | trak.io.min.js' else 'Tests | trak.io.js'

      trak.io.context({foo: 'bar'}).should.eql
        ip: null
        user_agent: navigator.userAgent
        page_title: title
        url: 'http://example.com/?a=b&c=d'
        referer: 'http://referer.com/?a=b&c=d'
        params: {a: 'b', c: 'd'}
        referer_params: {a: 'b', c: 'd'}
        foo: 'bar'
      trak.io.url.restore()
      trak.io.referer.restore()

    it "stores any additional contexts in a cookie", ->
      trak.io.context 'foo', 'bar'
      cookie.get("_trak_#{trak.io.api_token()}_context").should.eql JSON.stringify({foo: 'bar'})

    it "retrieve any additional contexts in a cookie", ->
      cookie.set "_trak_#{trak.io.api_token()}_context", JSON.stringify({foo: 'bar'})
      trak.io.context().foo.should.equal 'bar'


  describe '#channel', ()->

    it "returns the current hostname by default", ->
      trak.io.channel().should.equal window.location.hostname

    it "returns provided value if set", ->
      trak.io.channel('custom_channel').should.equal 'custom_channel'
      trak.io.channel().should.equal 'custom_channel'

    it "stores value in cookie", ->
      trak.io.channel 'cookie_channel'
      cookie.get("_trak_#{trak.io.api_token()}_channel").should.eql 'cookie_channel'

    it "retrieve any additional channel in a cookie", ->
      cookie.set "_trak_#{trak.io.api_token()}_channel", 'cookie_channel'
      trak.io.channel().should.equal 'cookie_channel'


  describe '#root_domain', ()->

    it "returns the current root domain by default", ->
      sinon.stub(trak.io, 'get_root_domain').returns('.lvh.me')
      trak.io.root_domain().should.equal '.lvh.me'
      trak.io.get_root_domain.restore()


    it "returns provided value if set", ->
      trak.io.root_domain('custom.lvh.me').should.equal 'custom.lvh.me'
      trak.io.root_domain().should.equal 'custom.lvh.me'


  describe '#get_root_domain', ()->

    it "returns ip address", ->
      sinon.stub(trak.io, 'hostname').returns '127.0.0.1'
      trak.io.get_root_domain().should.equal '127.0.0.1'
      trak.io.hostname.restore()

    it "returns 'localhost'", ->
      sinon.stub(trak.io, 'hostname').returns 'localhost'
      trak.io.get_root_domain().should.equal 'localhost'
      trak.io.hostname.restore()

    it "returns highest domain that a cookie can be set for", ->
      sinon.stub(trak.io, 'hostname').returns 'a.b.c.d'
      sinon.stub(trak.io, 'can_set_cookie', (options) -> options.domain == 'c.d' )
      trak.io.get_root_domain().should.equal 'c.d'
      trak.io.hostname.restore()

    it "returns provided value if set", ->
      trak.io.root_domain('custom.lvh.me').should.equal 'custom.lvh.me'
      trak.io.root_domain().should.equal 'custom.lvh.me'

  describe '#sign_out', ()->

    it "resets the distinct_id to a new randomly generateGUID", ()->
      trak.io.distinct_id('my_distinct_id')
      trak.io.sign_out()
      trak.io.distinct_id().should.not.eq 'my_distinct_id'
      cookie.get("_trak_#{trak.io.api_token()}_id").should.not.eq 'my_distinct_id'


    it "doesn't call alias", ()->
      sinon.stub(trak.io, 'alias')
      trak.io.sign_out()
      trak.io.alias.should.not.have.been.called
      trak.io.alias.restore()

