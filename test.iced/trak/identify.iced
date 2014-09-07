describe 'Trak', ->

  beforeEach ->
    sinon.stub(trak.io, 'call')
    trak.io.should_track(true)

  afterEach ->
    trak.io.distinct_id('another_distinct_id')
    trak.io.call.restore()

  describe '#identify(properties)', ->

    it "calls #call", ->
      properties = {foo: 'bar'}
      trak.io.identify(properties)
      trak.io.call.should.have.been.calledWith('identify', { data: { distinct_id: trak.io.distinct_id(), properties: properties } })

    it "sets should_track to true", ->
      properties = {foo: 'bar'}
      trak.io.should_track(false)
      trak.io.identify(properties)
      trak.io.should_track().should.equal true

    context "when distinct_id and company_id are both set", ->

      beforeEach ->
        trak.io.company_id('my_company_id')

      it "adds it to the company list", ->
        trak.io.identify({ company: { company_id: 'another_company_id' }, companies: [{ company_id: 'and_another' }] })
        # trak.io.call.should.have.been.calledWith('identify', { data: { distinct_id: trak.io.distinct_id(), properties: { company: [{ company_id: 'my_company_id' }, { company_id: 'another_company_id' }, { company_id: 'and_another' }] } } })

      context "but company_id is passed in as a property", ->

        it "doesn't send duplicates", ->
          trak.io.identify({ company: { company_id: 'my_company_id', role: 'sales' }, companies: [{ company_id: 'another_company_id' }] })
          trak.io.call.should.have.been.calledWith('identify', { data: { distinct_id: trak.io.distinct_id(), properties: { company: [{ company_id: 'my_company_id', role: 'sales' }, { company_id: 'another_company_id' }] } } })

    context "when company_id is a string", ->

      it "is moved into company_name", ->
        trak.io.identify({ company: 'my_company_name' })
        trak.io.call.should.have.been.calledWith('identify', { data: { distinct_id: trak.io.distinct_id(), properties: { company_name: 'my_company_name' } } })


  describe '#identify(properties, callback)', ->

    it "executes callback after identify responds", ->
      sinon.stub(trak.io, 'alias')
      properties = {foo: 'bar'}
      callback = sinon.spy()
      trak.io.identify(properties, callback)
      trak.io.call.should.have.been.calledWith('identify', { data: { distinct_id: trak.io.distinct_id(), properties: properties } }, callback)
      trak.io.alias.should.not.have.been.called
      trak.io.alias.restore()


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

    it "takes an numerical value for id", ->
      trak.io.identify(1234)
      trak.io.alias.should.have.been.calledWith('1234')

    context "when alias_on_identify is false", ->

      it "doesn't call alias", ->
        trak.io.alias_on_identify(false)
        trak.io.identify('my_distinct_id')
        trak.io.alias.should.not.have.been.called
        trak.io.alias_on_identify(true)


  describe '#identify(distinct_id, callback)', ->

    it "executes callback after alias responds", ->
      sinon.stub trak.io, 'alias', (distinct_id, callback) ->
        distinct_id.should.equal 'my_distinct_id'
        callback({ status: 'success' })
      callback = sinon.spy()
      trak.io.identify('my_distinct_id', callback)
      callback.should.have.been.calledWith({ status: 'success' })
      trak.io.alias.restore()


  describe '#identify(distinct_id, properties)', ->

    it "calls #call", ->
      properties = {foo: 'bar'}
      trak.io.identify('my_distinct_id', properties)
      trak.io.call.should.have.been.called
      trak.io.call.getCall(0).args[0].should.equal 'alias'
      trak.io.call.getCall(0).args[0].should.eql 'alias'
      trak.io.call.getCall(0).args[1].should.eql { data: { distinct_id: 'another_distinct_id', alias: 'my_distinct_id' } }
      trak.io.call.getCall(0).args[2]()
      trak.io.call.getCall(1).args[0].should.eql 'identify'
      trak.io.call.getCall(1).args[1].should.eql { data: { distinct_id: 'my_distinct_id', properties: properties } }

    it "sets the distinct_id", ->
      properties = {foo: 'bar'}
      trak.io.identify('my_distinct_id', properties)
      trak.io.distinct_id().should.equal 'my_distinct_id'
      cookie.get("_trak_#{trak.io.api_token()}_id").should.equal 'my_distinct_id'


  describe '#identify(distinct_id, properties, callback)', ->

    it "executes callback with alias data after alias and identify responses", ->
      sinon.stub trak.io, 'alias', (distinct_id, callback) ->
        distinct_id.should.equal 'my_distinct_id'
        callback()
      callback = sinon.spy()
      properties = {foo: 'bar'}
      trak.io.identify('my_distinct_id', properties, callback)
      trak.io.call.should.have.been.calledWith('identify', { data: { distinct_id: 'my_distinct_id', properties: { foo: "bar" } } }, callback)
      trak.io.alias.restore()

    it "executes callback with identify data after identify response and unnecessary alias", ->
      trak.io.distinct_id('my_distinct_id')
      callback = sinon.spy()
      properties = {foo: 'bar'}
      trak.io.identify('my_distinct_id', properties, callback)
      trak.io.call.should.have.been.calledWith('identify', { data: { distinct_id: 'my_distinct_id', properties: { foo: "bar" } } }, callback)

