requirejs ['trak','cookie'], (Trak, cookie) ->


  describe.only 'Trak', ->


    afterEach ->
      cookie.empty()
      trak.io._protocol = 'https'
      trak.io._host = 'api.trak.io'
      trak.io._current_context = false
      trak.io._medium = false
      trak.io._distinct_id = null


    describe '#initialize', ->

      it "stores api token", ->
        trak.io.initialize('api_token_value')
        trak.io.api_token().should.equal 'api_token_value'

      it "stores protocol option", ->
        trak.io.initialize('api_token_value', {protocol: 'http'})
        trak.io.protocol().should.equal 'http://'

      it "stores host option", ->
        trak.io.initialize('api_token_value', {host: 'custom_host.com'})
        trak.io.host().should.equal 'custom_host.com'

      it "stores context option", ->
        trak.io.initialize('api_token_value', {context: {foo: 'bar'}})
        trak.io.current_context().should.eql {foo: 'bar'}

      it "stores medium option", ->
        trak.io.initialize('api_token_value', {medium: 'custom_medium'})
        trak.io.medium().should.equal 'custom_medium'

      it "stores distinct_id option", ->
        trak.io.initialize('api_token_value', {distinct_id: 'custom_distinct_id'})
        trak.io.distinct_id().should.equal 'custom_distinct_id'

      it "set up default options", ->
        trak = new Trak()
        trak.io.initialize('api_token_value')
        trak.io.protocol().should.equal 'https://'
        trak.io.host().should.equal 'api.trak.io'
        trak.io.current_context().should.eql {}
        trak.io.medium().should.equal 'web_site'

      it.only "calls #page_view", ->
        sinon.stub(trak.io, 'track')
        sinon.stub(trak.io, 'url').returns('page_url')
        sinon.stub(trak.io, 'page_title').returns('A page title')
        trak.io.initialize('api_token_value')
        trak.io.track.should.have.been.calledWith('page_view', { url: 'page_url', page_title: 'A page title' })
        trak.io.track.restore()
        trak.io.page_title.restore()
        trak.io.url.restore()

      it "doesn't call #page_view if track_page_views", ->
        sinon.stub(trak.io, 'track')
        sinon.stub(trak.io, 'url').returns('page_url')
        sinon.stub(trak.io, 'page_title').returns('A page title')
        trak.io.initialize('api_token_value', { track_page_views: false })
        trak.io.track.should.not.have.been.called
        trak.io.track.restore()
        trak.io.page_title.restore()
        trak.io.url.restore()


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
        cookie.set("_trak_#{trak.io.api_token()}_id",'distinct_id_value')
        trak.io.distinct_id().should.equal 'distinct_id_value'


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

      it "returns referrer by default", ->
        sinon.stub(trak.io, 'referrer').returns('http://referrer.com/?a=b&c=d')
        trak.io.context().referrer.should.equal('http://referrer.com/?a=b&c=d')
        trak.io.referrer.restore()

      it "returns referrer params by default", ->
        sinon.stub(trak.io, 'referrer').returns('http://referrer.com/?a=b&c=d')
        trak.io.context().referrer_params.should.eql({a: 'b', c: 'd'})
        trak.io.referrer.restore()

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
        sinon.stub(trak.io, 'referrer').returns('http://referrer.com/?a=b&c=d')
        trak.io.context({foo: 'bar'}).should.eql
          ip: null
          user_agent: navigator.userAgent
          url: 'http://example.com/?a=b&c=d',
          referrer: 'http://referrer.com/?a=b&c=d',
          params: {a: 'b', c: 'd'}
          referrer_params: {a: 'b', c: 'd'}
          foo: 'bar'
        trak.io.url.restore()
        trak.io.referrer.restore()

      it "stores any additional contexts in a cookie", ->
        trak.io.context 'foo', 'bar'
        cookie.get("_trak_#{trak.io.api_token()}_context").should.eql JSON.stringify({foo: 'bar'})

      it "retrieve any additional contexts in a cookie", ->
        cookie.set "_trak_#{trak.io.api_token()}_context", JSON.stringify({foo: 'bar'})
        trak.io.context().foo.should.equal 'bar'


    describe '#medium', ()->

      it "returns 'web_site' by default", ->
        trak.io.medium().should.equal 'web_site'

      it "returns provided value if set", ->
        trak.io.medium('custom_medium').should.equal 'custom_medium'
        trak.io.medium().should.equal 'custom_medium'

      it "stores value in cookie", ->
        trak.io.medium 'cookie_medium'
        cookie.get("_trak_#{trak.io.api_token()}_medium").should.eql 'cookie_medium'

      it "retrieve any additional medium in a cookie", ->
        cookie.set "_trak_#{trak.io.api_token()}_medium", 'cookie_medium'
        trak.io.medium().should.equal 'cookie_medium'



