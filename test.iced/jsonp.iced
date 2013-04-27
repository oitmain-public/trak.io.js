requirejs ['jsonp','exceptions'], (JSONP, Exceptions) ->

  describe 'JSONP', ->

    jsonp = new JSONP()

    afterEach ->
      cookie.empty()
      trak.io._protocol = 'https'
      trak.io._host = 'api.trak.io'
      trak.io._current_context = false
      trak.io._channel = false
      trak.io._distinct_id = null

    describe '#call', ->

      after ->
        jsonp.jsonp.restore();
        jsonp.url.restore();

      it "calls jsonp passing endpoint and params through #url", ->
        jsonp_method = sinon.stub(jsonp, "jsonp")
        sinon.stub(jsonp, "url").returns('the url to call')
        jsonp.call('endpoint')
        jsonp_method.should.have.been.calledWith('the url to call')


    describe '#callback', ->

      it "does nothing when request is a success", ->
        expect(->
          jsonp.callback({status: 'success'})
        ).to.not.throw(Error)

      it "raises a DataObjectInvalid exception", ->
        expect(->
          jsonp.callback({ status: "error", exception: "TrakioAPI::Exceptions::DataObjectInvalid" })
        ).to.throw(Exceptions.DataObjectInvalid)

      it "raises a DuplicatedDistinctIds exception", ->
        expect(->
          jsonp.callback({ status: "error", exception: "TrakioAPI::Exceptions::DuplicatedDistinctIds" })
        ).to.throw(Exceptions.DuplicatedDistinctIds)

      it "raises a InternalServiceError exception", ->
        expect(->
          jsonp.callback({ status: "error", exception: "TrakioAPI::Exceptions::InternalServiceError" })
        ).to.throw(Exceptions.InternalServiceError)

      it "raises a InvalidToken exception", ->
        expect(->
          jsonp.callback({ status: "error", exception: "TrakioAPI::Exceptions::InvalidToken" })
        ).to.throw(Exceptions.InvalidToken)

      it "raises a MissingParameter exception", ->
        expect(->
          jsonp.callback({ status: "error", exception: "TrakioAPI::Exceptions::MissingParameter" })
        ).to.throw(Exceptions.MissingParameter)

      it "raises a PersonNotFound exception", ->
        expect(->
          jsonp.callback({ status: "error", exception: "TrakioAPI::Exceptions::PersonNotFound" })
        ).to.throw(Exceptions.PersonNotFound)

      it "raises a PropertiesObjectInvalid exception", ->
        expect(->
          jsonp.callback({ status: "error", exception: "TrakioAPI::Exceptions::PropertiesObjectInvalid" })
        ).to.throw(Exceptions.PropertiesObjectInvalid)

      it "raises a RouteNotFound exception", ->
        expect(->
          jsonp.callback({ status: "error", exception: "TrakioAPI::Exceptions::RouteNotFound" })
        ).to.throw(Exceptions.RouteNotFound)

      it "raises a Timeout exception", ->
        expect(->
          jsonp.callback({ status: "error", exception: "TrakioAPI::Exceptions::Timeout" })
        ).to.throw(Exceptions.Timeout)

      it "raises an Unknown exception if exception is unknown", ->
        expect(->
          jsonp.callback({ status: "error", exception: "TrakioAPI::Exceptions::NotAKnownException" })
        ).to.throw(Exceptions.Unknown)

      it "sets the exception's code", ->
        try
          jsonp.callback({ status: "error", code: 123 })
        catch error
          error.code.should.equal 123

      it "sets the exception's message", ->
        try
          jsonp.callback({ status: "error", message: "my message" })
        catch error
          error.message.should.equal "my message"

      it "sets the exception's details", ->
        try
          jsonp.callback({ status: "error", details: "my details" })
        catch error
          error.details.should.equal "my details"

      it "sets the exception's data", ->
        try
          jsonp.callback({ status: "error", foo: "bar" })
        catch error
          error.data.should.deep.equal { status: "error", foo: "bar" }


    describe '#url', ->

      afterEach ->
        trak.io.protocol.restore()
        trak.io.host.restore()
        jsonp.default_params.restore()

      it "joins Trak#protocol Trak#host / endpoint and params for endpoint", ->
        sinon.stub(trak.io, "protocol").returns('mcp://')
        sinon.stub(trak.io, "host").returns('my_host.com')
        sinon.stub(jsonp, "default_params").returns({ override: 'foo', keep: 'foo' })
        jsonp.url('my_endpoint', { override: 'bar' }).should.equal('mcp://my_host.com/my_endpoint?override=bar&keep=foo')


    describe '#params', ->

      afterEach ->
        jsonp.default_params.restore();

      it "merges provided params with defaults for endpoint", ->
        sinon.stub(jsonp, 'default_params').returns({ override: 'foo', keep: 'foo' })
        jsonp.params('endpoint', { override: 'bar' }).should.equal "?override=bar&keep=foo"

      it "merges nested objects and encodes them to json", ->
        sinon.stub(jsonp, 'default_params').returns({ top: 'top', nested: { override: 'foo', keep: 'foo', second: { override: 'foo', keep: 'foo' }}})
        jsonp.params('endpoint', { nested: { override: 'bar', second: { override: 'bar'}}}).should.equal '?top=top&nested='+encodeURIComponent('{"override":"bar","keep":"foo","second":{"override":"bar","keep":"foo"}}')

      it "merges arrays and encodes them to json", ->
        sinon.stub(jsonp, 'default_params').returns({ top: 'top', array: ['foo','duplicate']})
        jsonp.params('endpoint', { array: ['duplicate','bar']}).should.equal '?top=top&array='+encodeURIComponent('["foo","duplicate","bar"]')


    describe '#default_params', ->

      beforeEach ->
        sinon.stub(trak.io, "distinct_id").returns('distinct_id_value')
        sinon.stub(trak.io, "api_token").returns('api_token_value')
        sinon.stub(trak.io, "channel").returns('channel_value')
        sinon.stub(trak.io, "context").returns('context_value')

      afterEach ->
        trak.io.distinct_id.restore();
        trak.io.api_token.restore();
        trak.io.channel.restore();
        trak.io.context.restore();

      it "returns default params for alias", ->
        jsonp.default_params('alias').should.eql({ token: 'api_token_value', data: { distinct_id: 'distinct_id_value', time: new Date() }})

      it "returns default params for identify", ->
        jsonp.default_params('identify').should.eql({ token: 'api_token_value', data: { distinct_id: 'distinct_id_value', time: new Date(), properties: {} }})

      it "returns default params for track", ->
        jsonp.default_params('track').should.eql({ token: 'api_token_value', data: { distinct_id: 'distinct_id_value', time: new Date(), properties: {}, channel: 'channel_value', context: 'context_value' }})

      it "returns empty object for unknown", ->
        jsonp.default_params('jibersih').should.eql {}


    describe '#noop', ->

      it "does nothing, zip, nadda", ->
        expect(jsonp.noop()).to.equal undefined


    describe '#jsonp', ->

      it "creates and inserts a script tag for the provided url", ->
        jsonp.jsonp('/empty.json')
        $("script[src^='/empty.json']").should.exist

      it "adds its own callback param", ->
        jsonp.jsonp('/empty.json')
        $("script[src$='callback=__trak#{jsonp.count-1}']").should.exist

      it "when __trak* called cleans up and calls callback", ->
        callback = sinon.stub(jsonp, 'callback')
        jsonp.jsonp('/empty.json')
        window["__trak#{jsonp.count-1}"]({some: 'data'})
        callback.should.have.been.calledWith({some: 'data'})
        $("script[src$='callback=__trak#{jsonp.count-1}']").should.not.exist
        callback.restore()

      it "triggers #callback with timeout error if script hasn't executed by timeout", ->
        clock = sinon.useFakeTimers()
        callback = sinon.stub(jsonp, 'callback')
        jsonp.jsonp('/empty.json')
        clock.tick(10001)
        callback.should.have.been.calledWith({ status: 'error', exception: 'TrakioAPI::Exceptions::Timeout', message: "The server failed to respond in time."})
        $("script[src$='callback=__trak#{jsonp.count-1}']").should.not.exist
        clock.restore()
        callback.restore()


