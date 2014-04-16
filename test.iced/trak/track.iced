describe  'Trak', ->

  Exceptions = null

  before (done)->
    requirejs ['exceptions'], (E) ->
      Exceptions = E
      done()

  beforeEach ->
    sinon.stub(trak.io, 'call')
    sinon.stub(trak.io, 'distinct_id').returns('default_distinct_id')
    sinon.stub(trak.io, 'context').returns({default: 'context', override: 'override'})
    sinon.stub(trak.io, 'channel').returns('default_channel')

  afterEach ->
    trak.io.call.restore()
    trak.io.distinct_id.restore()
    trak.io.context.restore()
    trak.io.channel.restore()

  describe '#track()', ->

    it "raises Exceptions.MissingParameter", ->
      expect ->
        trak.io.track()
      .to.throw trak.Exceptions.MissingParameter

  describe '#track(event)', ->

    it "calls #call", ->
      trak.io.track('my_event')
      trak.io.call.should.have.been.calledWith('track', { data: { distinct_id: 'default_distinct_id', event: 'my_event', channel: 'default_channel', context: { default: 'context', override: 'override'}, properties: {}}}, null)


  describe '#track(event, properties)', ->

    it "calls #call", ->
      properties = {foo: 'bar'}
      trak.io.track('my_event', properties)
      trak.io.call.should.have.been.calledWith('track', { data: { distinct_id: 'default_distinct_id', event: 'my_event', channel: 'default_channel', context: { default: 'context', override: 'override'}, properties: properties}}, null)


  describe '#track(event, properties, context)', ->

    it "calls #call merging contexts", ->
      properties = {my: 'properties'}
      context = {my: 'context', override: 'overriden'}
      trak.io.track('my_event', properties, context)
      trak.io.call.should.have.been.calledWith('track', { data: { distinct_id: 'default_distinct_id', event: 'my_event', channel: 'default_channel', context: {default: 'context', override: 'overriden', my: 'context'}, properties: properties}}, null)

    it "doesn't change trak.io.context()", ->
      properties = {my: 'properties'}
      context = {my: 'context'}
      trak.io.track('my_event', properties, context)
      trak.io.context.should.have.been.calledWithExactly()

  describe '#track(event, channel)', ->

    it "calls #call", ->
      trak.io.track('my_event', 'my_channel')
      trak.io.call.should.have.been.calledWith('track', { data: { distinct_id: 'default_distinct_id', event: 'my_event', channel: 'my_channel', context: {default: 'context', override: 'override'}, properties: {}}}, null)


  describe '#track(event, channel, properties)', ->

    it "calls #call", ->
      properties = {foo: 'bar'}
      trak.io.track('my_event', 'my_channel', properties)
      trak.io.call.should.have.been.calledWith('track', { data: { distinct_id: 'default_distinct_id', event: 'my_event', channel: 'my_channel', context: {default: 'context', override: 'override'}, properties: properties}}, null)

    it "doesn't change trak.io.channel()", ->
      properties = {foo: 'bar'}
      trak.io.track('my_event', 'my_channel', properties)
      trak.io.channel().should.not.equal 'my_channel'

  describe '#track(event, channel, properties, context)', ->

    it "calls #call merging contexts", ->
      properties = {my: 'properties'}
      context = {my: 'context', override: 'overriden'}
      trak.io.track('my_event', 'my_channel', properties, context)
      trak.io.call.should.have.been.calledWith('track', { data: { distinct_id: 'default_distinct_id', event: 'my_event', channel: 'my_channel', context: {default: 'context', override: 'overriden', my: 'context'}, properties: properties}}, null)

    it "doesn't change trak.io.context()", ->
      properties = {my: 'properties'}
      context = {my: 'context'}
      trak.io.track('my_event', 'my_channel', properties, context)
      trak.io.context().should.not.equal context

    it "doesn't change trak.io.channel()", ->
      properties = {foo: 'bar'}
      context = {my: 'context'}
      trak.io.track('my_event', 'my_channel', properties, context)
      trak.io.channel().should.not.equal 'my_channel'


  describe '#track(distinct_id, event, channel)', ->

    it "calls #call", ->
      trak.io.track('my_distinct_id', 'my_event', 'my_channel')
      trak.io.call.should.have.been.calledWith('track', { data: { distinct_id: 'my_distinct_id', event: 'my_event', channel: 'my_channel', context: {default: 'context', override: 'override'}, properties: {}}}, null)

    it "doesn't change trak.io.distinct_id()", ->
      trak.io.track('my_distinct_id', 'my_event', 'my_channel')
      trak.io.distinct_id().should.not.equal 'my_distinct_id'

    it "doesn't change trak.io.channel()", ->
      trak.io.track('my_distinct_id', 'my_event', 'my_channel')
      trak.io.channel().should.not.equal 'my_channel'


  describe '#track(distinct_id, event, channel, properties)', ->

    it "calls #call", ->
      properties = {my: 'properties'}
      trak.io.track('my_distinct_id', 'my_event', 'my_channel', properties)
      trak.io.call.should.have.been.calledWith('track', { data: { distinct_id: 'my_distinct_id', event: 'my_event', channel: 'my_channel', context: {default: 'context', override: 'override'}, properties: properties}}, null)

    it "doesn't change trak.io.distinct_id()", ->
      properties = {my: 'properties'}
      trak.io.track('my_distinct_id', 'my_event', 'my_channel', properties)
      trak.io.distinct_id().should.not.equal 'my_distinct_id'

    it "doesn't change trak.io.channel()", ->
      properties = {my: 'properties'}
      trak.io.track('my_distinct_id', 'my_event', 'my_channel', properties)
      trak.io.channel().should.not.equal 'my_channel'


  describe '#track(distinct_id, event, channel, properties, context)', ->

    it "calls #call merging contexts", ->
      properties = {my: 'properties'}
      context = {my: 'context', override: 'overriden'}
      trak.io.track('my_distinct_id', 'my_event', 'my_channel', properties, context)
      trak.io.call.should.have.been.calledWith('track', { data: { distinct_id: 'my_distinct_id', event: 'my_event', channel: 'my_channel', context: {default: 'context', override: 'overriden', my: 'context'}, properties: properties}}, null)

    it "doesn't change trak.io.distinct_id()", ->
      properties = {my: 'properties'}
      context = {my: 'context'}
      trak.io.track('my_distinct_id', 'my_event', 'my_channel', properties, context)
      trak.io.distinct_id().should.not.equal 'my_distinct_id'

    it "doesn't change trak.io.channel()", ->
      properties = {my: 'properties'}
      context = {my: 'context'}
      trak.io.track('my_distinct_id', 'my_event', 'my_channel', properties, context)
      trak.io.channel().should.not.equal 'my_channel'

    it "doesn't change trak.io.context()", ->
      properties = {my: 'properties'}
      context = {my: 'context'}
      trak.io.track('my_distinct_id', 'my_event', 'my_channel', properties, context)
      trak.io.context().should.not.equal context

