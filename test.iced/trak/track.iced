requirejs ['exceptions'], (Exceptions) ->

  describe  'Trak', ->

    before ->
      sinon.stub(trak.io, 'call')
      sinon.stub(trak.io, 'distinct_id').returns('default_distinct_id')
      sinon.stub(trak.io, 'context').returns({default: 'context'})
      sinon.stub(trak.io, 'medium').returns('default_medium')

    after ->
      trak.io.call.restore()
      trak.io.distinct_id.restore()
      trak.io.context.restore()
      trak.io.medium.restore()

    describe '#track()', ->

      it "raises Exceptions.MissingParameter", ->
        expect ->
          trak.io.track()
        .to.throw Exceptions.MissingParameter

    describe '#track(event)', ->

      it "calls #call", ->
        trak.io.track('my_event')
        trak.io.call.should.have.been.calledWith('track', { data: { distinct_id: 'default_distinct_id', event: 'my_event', medium: 'default_medium', context: { default: 'context'}, properties: {}}})


    describe '#track(event, properties)', ->

      it "calls #call", ->
        properties = {foo: 'bar'}
        trak.io.track('my_event', properties)
        trak.io.call.should.have.been.calledWith('track', { data: { distinct_id: 'default_distinct_id', event: 'my_event', medium: 'default_medium', context: { default: 'context'}, properties: properties}})


    describe '#track(event, properties, context)', ->

      it "calls #call merging contexts", ->
        properties = {my: 'properties'}
        context = {my: 'context'}
        trak.io.track('my_event', properties, context)
        trak.io.call.should.have.been.calledWith('track', { data: { distinct_id: 'default_distinct_id', event: 'my_event', medium: 'default_medium', context: {default: 'context', my: 'context'}, properties: properties}})

      it "doesn't change trak.io.context()", ->
        properties = {my: 'properties'}
        context = {my: 'context'}
        trak.io.track('my_event', properties, context)
        trak.io.context.should.have.been.calledWithExactly()

    describe '#track(event, medium)', ->

      it "calls #call", ->
        trak.io.track('my_event', 'my_medium')
        trak.io.call.should.have.been.calledWith('track', { data: { distinct_id: 'default_distinct_id', event: 'my_event', medium: 'my_medium', context: {default: 'context'}, properties: {}}})


    describe '#track(event, medium, properties)', ->

      it "calls #call", ->
        properties = {foo: 'bar'}
        trak.io.track('my_event', 'my_medium', properties)
        trak.io.call.should.have.been.calledWith('track', { data: { distinct_id: 'default_distinct_id', event: 'my_event', medium: 'my_medium', context: {default: 'context'}, properties: properties}})

      it "doesn't change trak.io.medium()", ->
        properties = {foo: 'bar'}
        trak.io.track('my_event', 'my_medium', properties)
        trak.io.medium.should.have.been.calledWithExactly()

    describe '#track(event, medium, properties, context)', ->

      it "calls #call merging contexts", ->
        properties = {my: 'properties'}
        context = {my: 'context'}
        trak.io.track('my_event', 'my_medium', properties, context)
        trak.io.call.should.have.been.calledWith('track', { data: { distinct_id: 'default_distinct_id', event: 'my_event', medium: 'my_medium', context: {default: 'context', my: 'context'}, properties: properties}})

      it "doesn't change trak.io.context()", ->
        properties = {my: 'properties'}
        context = {my: 'context'}
        trak.io.track('my_event', 'my_medium', properties, context)
        trak.io.context.should.have.been.calledWithExactly()

      it "doesn't change trak.io.medium()", ->
        properties = {foo: 'bar'}
        context = {my: 'context'}
        trak.io.track('my_event', 'my_medium', properties, context)
        trak.io.medium.should.have.been.calledWithExactly()


    describe '#track(distinct_id, event, medium)', ->

      it "calls #call", ->
        trak.io.track('my_distinct_id', 'my_event', 'my_medium')
        trak.io.call.should.have.been.calledWith('track', { data: { distinct_id: 'my_distinct_id', event: 'my_event', medium: 'my_medium', context: {default: 'context'}, properties: {}}})

      it "doesn't change trak.io.distinct_id()", ->
        trak.io.track('my_distinct_id', 'my_event', 'my_medium')
        trak.io.distinct_id.should.have.been.calledWithExactly()

      it "doesn't change trak.io.medium()", ->
        trak.io.track('my_distinct_id', 'my_event', 'my_medium')
        trak.io.medium.should.have.been.calledWithExactly()


    describe '#track(distinct_id, event, medium, properties)', ->

      it "calls #call", ->
        properties = {my: 'properties'}
        trak.io.track('my_distinct_id', 'my_event', 'my_medium', properties)
        trak.io.call.should.have.been.calledWith('track', { data: { distinct_id: 'my_distinct_id', event: 'my_event', medium: 'my_medium', context: {default: 'context'}, properties: properties}})

      it "doesn't change trak.io.distinct_id()", ->
        properties = {my: 'properties'}
        trak.io.track('my_distinct_id', 'my_event', 'my_medium', properties)
        trak.io.distinct_id.should.have.been.calledWithExactly()

      it "doesn't change trak.io.medium()", ->
        properties = {my: 'properties'}
        trak.io.track('my_distinct_id', 'my_event', 'my_medium', properties)
        trak.io.medium.should.have.been.calledWithExactly()


    describe '#track(distinct_id, event, medium, properties, context)', ->

      it "calls #call merging contexts", ->
        properties = {my: 'properties'}
        context = {my: 'context'}
        trak.io.track('my_distinct_id', 'my_event', 'my_medium', properties, context)
        trak.io.call.should.have.been.calledWith('track', { data: { distinct_id: 'my_distinct_id', event: 'my_event', medium: 'my_medium', context: {default: 'context', my: 'context'}, properties: properties}})

      it "doesn't change trak.io.distinct_id()", ->
        properties = {my: 'properties'}
        context = {my: 'context'}
        trak.io.track('my_distinct_id', 'my_event', 'my_medium', properties, context)
        trak.io.distinct_id.should.have.been.calledWithExactly()

      it "doesn't change trak.io.medium()", ->
        properties = {my: 'properties'}
        context = {my: 'context'}
        trak.io.track('my_distinct_id', 'my_event', 'my_medium', properties, context)
        trak.io.medium.should.have.been.calledWithExactly()

      it "doesn't change trak.io.context()", ->
        properties = {my: 'properties'}
        context = {my: 'context'}
        trak.io.track('my_distinct_id', 'my_event', 'my_medium', properties, context)
        trak.io.context.should.have.been.calledWithExactly()



