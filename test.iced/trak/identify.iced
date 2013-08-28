requirejs [], () ->
  describe 'Trak', ->

    beforeEach ->
      sinon.stub(trak.io, 'call')


    afterEach ->
      trak.io.call.restore()


    describe '#identify(properties)', ->

      it "calls #call", ->
        properties = {foo: 'bar'}
        trak.io.identify(properties)
        trak.io.call.should.have.been.calledWith('identify', { distinct_id: trak.io.distinct_id(), data: { properties: properties } })


    describe '#identify(distinct_id)', ->

      beforeEach ->
        sinon.stub(trak.io, 'alias')

      afterEach ->
        trak.io.alias.restore()

      it "doesn't bother with #call", ->
        trak.io.identify('my_distinct_id')
        trak.io.call.should.not.have.been.calledWith('identify')

      it "calls alias with the distinct_id", ->
        trak.io.identify('my_distinct_id')
        trak.io.alias.should.have.been.calledWith('my_distinct_id')


    describe '#identify(distinct_id, callback)', ->

      it "executes callback immediately", ->
        callback = sinon.spy()
        trak.io.identify('my_distinct_id', callback)
        callback.should.have.been.calledWith({status: 'unnecessary'})



    describe '#identify(distinct_id, properties)', ->

      it "calls #call", ->
        properties = {foo: 'bar'}
        trak.io.identify('my_distinct_id', properties)
        trak.io.call.should.have.been.calledWith('identify', { distinct_id: 'my_distinct_id', data: { properties: properties } })

      it "sets the distinct_id", ->
        properties = {foo: 'bar'}
        trak.io.identify('my_distinct_id', properties)
        trak.io.distinct_id().should.equal 'my_distinct_id'
        cookie.get("_trak_#{trak.io.api_token()}_id").should.equal 'my_distinct_id'


