describe 'trakio/automagic', ->

  _=null
  automagic = memoize().as -> new Trak.Automagic()
  automagic_initialized = memoize().as -> automagic().initialize(automagic_options())
  automagic_options = memoize().as -> {}
  form = memoize().as_haml """
    %form.my_form
      %input
  """
  second_form = memoize().as_haml """
    %form.a_form
      %input
  """
  event = memoize().as -> new MockEvent('submit',form())

  before (done)->
    requirejs ['trakio/lodash'], (lodash) ->
      _=lodash
      done()

  describe '#initialize', ->

    it "initializes Automagic.Identify", ->
      automagic_initialized().identify.should.be.an.instanceof Trak.Automagic.Identify


    it "calls #page_ready if trak.io.page_ready_event_fired is true", ->
      trak.io.page_ready_event_fired = true
      sinon.stub(automagic(), 'page_ready')
      automagic().initialize()
      automagic().page_ready.should.have.been.called


    it "dosen't call #page_ready if trak.io.page_ready_event_fired is false", ->
      trak.io.page_ready_event_fired = false
      sinon.stub(automagic(), 'page_ready')
      automagic().initialize()
      automagic().page_ready.should.not.have.been.called


  describe '#page_ready', ->

    it "adds data-trakio-automagic attribute to body", ->
      automagic_initialized().page_ready()

      document.body.hasAttribute('data-trakio-automagic').should.eql true


    it "calls #bind_events", ->
      sinon.stub(automagic(), 'bind_events')
      automagic_initialized().page_ready()
      automagic().bind_events.should.have.been.called


    context "when bind events is false", ->
      value(automagic_options).equals { bind_events: false }

      it "doesn't call #bind_events", ->
        sinon.stub(automagic(), 'bind_events')

        automagic_initialized().page_ready()
        automagic().bind_events.should.not.have.been.called


    it "calls trakio/automagic/identify#page_ready", ->
      sinon.stub(automagic_initialized().identify, 'page_ready')

      automagic().page_ready()
      automagic().identify.page_ready.should.have.been.called


  describe '#bind_events', ->

    it "binds to all forms' submit", ->
      sinon.stub(automagic(), 'bind_to_form_submit')
      form()
      second_form()
      automagic_initialized().bind_events()

      automagic().bind_to_form_submit.should.have.been.calledWith(form())
      automagic().bind_to_form_submit.should.have.been.calledWith(second_form())


    context "when there is a form that doesn't match", ->

      value(automagic_options).equals -> { form_selector: '.my_form'}

      it "only binds to matching forms", ->
        sinon.stub(automagic(), 'bind_to_form_submit')
        form()
        second_form()

        automagic_initialized().bind_events()

        automagic().bind_to_form_submit.should.have.been.calledWith(form())
        automagic().bind_to_form_submit.should.not.have.been.calledWith(second_form())


  describe '#bind_to_form_submit', ->

    it 'adds a callback to the form', ->
      sinon.stub(form(), 'addEventListener')

      automagic().bind_to_form_submit(form())

      form().addEventListener.should.have.been.calledWith('submit',automagic().form_submitted)


  describe '#form_submitted', ->

    it "calls trakio/automagic/identify#form_submitted", ->
      sinon.stub(automagic_initialized().identify, 'form_submitted').returns(false)

      automagic().form_submitted(event())

      automagic().identify.form_submitted.should.have.been.calledWith(event())

