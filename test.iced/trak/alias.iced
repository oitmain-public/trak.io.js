requirejs [], () ->
  describe 'Trak', ->

    beforeEach ->
      trak.io._distinct_id = 'old_distinct_id'
      sinon.stub(trak.io, 'call')

    afterEach ->
      trak.io.call.restore()
      trak.io._distinct_id = null

    describe '#alias()', ->

      it "raises Exceptions.MissingParameter", ->
        expect ->
          trak.io.alias()
        .to.throw trak.Exceptions.MissingParameter


    describe '#alias(alias)', ->

      it "calls #call", ->
        trak.io._distinct_id = 'old_distinct_id'
        trak.io.alias('my_alias')
        trak.io.call.should.have.been.calledWith('alias', { data: { distinct_id: 'old_distinct_id', alias: 'my_alias' } })

      it "sets current distinct_id to the alias", ->
        trak.io._distinct_id = 'old_distinct_id'
        trak.io.alias('my_alias')
        trak.io.distinct_id().should.equal 'my_alias'
        cookie.get("_trak_#{trak.io.api_token()}_id").should.equal 'my_alias'

      it "doesn't make a call if the alias is the same as the current distinct_id", ->
        trak.io._distinct_id = 'bbb'
        trak.io.alias('bbb')
        trak.io.call.should.not.have.been.called



    describe '#alias(alias, false)', ->

      it "calls #call", ->
        trak.io.alias('my_alias')
        trak.io.call.should.have.been.calledWith('alias', { data: { distinct_id: 'old_distinct_id', alias: 'my_alias' } })

      it "doesn't set current distinct_id to the alias", ->
        previous_id = trak.io.distinct_id()
        trak.io.alias('my_alias', false)
        trak.io.distinct_id().should.equal previous_id
        cookie.get("_trak_#{trak.io.api_token()}_id").should.equal previous_id


    describe '#alias(distinct_id, alias)', ->

      it "calls #call", ->
        trak.io.alias('custom_distinct_id', 'my_alias')
        trak.io.call.should.have.been.calledWith('alias', { data: { distinct_id: 'custom_distinct_id', alias: 'my_alias' } })

      it "doesn't set current distinct_id to the alias", ->
        previous_id = trak.io.distinct_id()
        trak.io.alias('custom_distinct_id', 'my_alias')
        trak.io.distinct_id().should.equal previous_id
        cookie.get("_trak_#{trak.io.api_token()}_id").should.equal previous_id

      it "doesn't make a call if the alias is the same as the distinct_id", ->
        trak.io.alias('aaa','aaa')
        trak.io.call.should.not.have.been.called



