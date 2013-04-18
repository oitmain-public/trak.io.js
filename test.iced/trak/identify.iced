requirejs [], () ->
  describe 'Trak', ->

    before ->
      sinon.stub(trak.io, 'call')


    after ->
      trak.io.call.restore()


    describe '#identify(properties)', ->

      it "calls #call", ->
        properties = {foo: 'bar'}
        trak.io.identify(properties)
        trak.io.call.should.have.been.calledWith('identify', { distinct_id: trak.io.distinct_id(), data: { properties: properties } })


    describe '#identify(distinct_id)', ->

      it "calls #call", ->
        trak.io.identify('my_distinct_id')
        trak.io.call.should.have.been.calledWith('identify', { distinct_id: 'my_distinct_id', data: { properties: {} } })

      it "sets the distinct_id", ->
        trak.io.identify('my_distinct_id')
        trak.io.distinct_id().should.equal 'my_distinct_id'
        cookie.get("_trak_#{trak.io.api_token()}_id").should.equal 'my_distinct_id'



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


