describe 'Trak', ->

  beforeEach ->
    sinon.stub(trak.io, 'call')
    trak.io.distinct_id('my_distinct_id')
    trak.io.company_id('company_id')
    trak.io.should_track(true)

  afterEach ->
    trak.io.call.restore()

  describe '#company(properties)', ->

    it "calls #call", ->
      properties = { foo: 'bar' }
      trak.io.company_id('company_id')
      trak.io.company(properties)
      trak.io.call.should.have.been.calledWith('company', { data: { company_id: trak.io.company_id(), properties: properties, people_distinct_ids: ["my_distinct_id"] } })

    context "when company_id has not been provided", ->


      it "raises Exceptions.MissingParameter", ->
        expect ->
          trakio = new Trak()
          sinon.stub(trakio, 'call')
          trakio.initialize('api_token_value_2')
          trakio.sign_out()
          trakio.company { foo: 'bar' }
        .to.throw trak.Exceptions.MissingParameter


  describe '#company(properties, callback)', ->

    it "executes callback after company responds", ->
      properties = {foo: 'bar'}
      callback = sinon.spy()
      trak.io.company(properties, callback)
      trak.io.call.should.have.been.calledWith('company', { data: { company_id: trak.io.company_id(), properties: properties, people_distinct_ids: ["my_distinct_id"] } }, callback)


  describe '#company(company_id)', ->

    context "when distinct_id is set", ->

      it "sends it in the people_distinct_ids parameter", ->
        trakio = new Trak()
        sinon.stub(trakio, 'call')
        trakio.company_id('my_company_id')
        trakio.distinct_id('my_distinct_id')
        trakio.company()
        trakio.call.should.have.been.calledWith('company', { data: { company_id: 'my_company_id', people_distinct_ids: ['my_distinct_id'] } })

  describe '#company(company_id, properties)', ->

    it "calls #call", ->
      properties = {foo: 'bar'}
      trak.io.company('my_company_id', properties)
      trak.io.call.should.have.been.called
      trak.io.call.getCall(0).args[0].should.eql 'company'
      trak.io.call.getCall(0).args[1].should.eql { data: { company_id: 'my_company_id', people_distinct_ids: ["my_distinct_id"], properties: properties } }

    it "sets the company_id", ->
      properties = {foo: 'bar'}
      trak.io.company('my_company_id', properties)
      trak.io.company_id().should.equal 'my_company_id'
      cookie.get("_trak_#{trak.io.api_token()}_company_id").should.equal 'my_company_id'


  describe '#company(company_id, properties, callback)', ->

    it "executes callback with company data after company responds", ->
      trak.io.company_id('my_company_id')
      callback = sinon.spy()
      properties = {foo: 'bar'}
      trak.io.company('my_company_id', properties, callback)
      trak.io.call.should.have.been.calledWith('company', { data: { company_id: 'my_company_id', properties: { foo: "bar" }, people_distinct_ids: ["my_distinct_id"] } }, callback)

