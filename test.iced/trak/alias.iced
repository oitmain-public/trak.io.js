requirejs ['exceptions'], (Exceptions) ->
  describe 'Trak', ->

    before ->
      sinon.stub(trak.io, 'call')
      trak.io._distinct_id = null


    after ->
      trak.io.call.restore()
      trak.io._distinct_id = null

    describe '#alias()', ->

      it "raises Exceptions.MissingParameter", ->
        expect ->
          trak.io.alias()
        .to.throw Exceptions.MissingParameter


    describe '#alias(alias)', ->

      it "calls #call", ->
        previous_id = trak.io.distinct_id()
        trak.io.alias('my_alias')
        trak.io.call.should.have.been.calledWith('alias', { data: { distinct_id: previous_id, alias: 'my_alias' } })

      it "sets current distinct_id to the alias", ->
        trak.io.alias('my_alias')
        trak.io.distinct_id().should.equal 'my_alias'
        cookie.get("_trak_#{trak.io.api_token()}_id").should.equal 'my_alias'


    describe '#alias(alias, false)', ->

      it "calls #call", ->
        trak.io.alias('my_alias')
        trak.io.call.should.have.been.calledWith('alias', { data: { distinct_id: trak.io.distinct_id(), alias: 'my_alias' } })

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


