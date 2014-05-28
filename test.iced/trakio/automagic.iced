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
      %input{type: "text"}
      %input{type: "submit"}
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

    afterEach ->
      if document.body.addEventListener.restore
        document.body.addEventListener.restore()

    context "when submit bubbles", ->
      it "binds submit on body", ->
        addEventListener = sinon.stub(document.body, 'addEventListener')
        sinon.stub(automagic(), 'submit_bubbles').returns(true)

        automagic_initialized().bind_events()

        addEventListener.should.have.been.calledOnce
        addEventListener.should.have.been.calledWith('submit')

        addEventListener.restore()

    context "when submit does not bubble", ->
      it "binds click and keypress on body", ->
        addEventListener = sinon.stub(document.body, 'addEventListener')
        sinon.stub(automagic(), 'submit_bubbles').returns(false)

        automagic_initialized().bind_events()

        addEventListener.should.have.been.calledTwice
        addEventListener.should.have.been.calledWith('click')
        addEventListener.should.have.been.calledWith('keypress')

        addEventListener.restore()


  describe '#emulated_form_submitted', ->

    context "when it's triggered by a click", ->

      it "should call form_submitted if it's a submit button", ->
        stub = sinon.stub(automagic(), 'form_submitted').returns(false)

        second_form()
        submit = $('input[type=submit]')[0]
        _event = new MockEvent 'click', submit

        automagic_initialized().emulated_form_submitted(_event)

        stub.should.have.been.called
        stub.restore()

    context "when it's triggered by a keypress", ->

      it "should call form_submitted if it's an enter key", ->
        stub = sinon.stub(automagic(), 'form_submitted').returns(false)

        second_form()
        text = $('input[type=text]')[0]
        _event = new MockEvent 'keypress', text, keyCode: 13

        automagic_initialized().emulated_form_submitted(_event)

        stub.should.have.been.called
        stub.restore()



  describe '#form_submitted', ->

    it "calls trakio/automagic/identify#form_submitted", ->
      sinon.stub(automagic_initialized().identify, 'form_submitted').returns(false)

      automagic().form_submitted(event())

      automagic().identify.form_submitted.should.have.been.calledWith(event())

