describe 'trakio/automagic/track', ->

  _
  form = memoize().as_haml ""
  event = memoize().as -> new MockEvent('submit', form(), { automagic_ready: {}, callback: callback() })
  automagic = memoize().as -> new Trak.Automagic().initialize(automagic_options())
  automagic_options = memoize().as -> {}
  callback = memoize().as -> sinon.spy()

  before (done)->
    requirejs ['trakio/lodash'], (lodash) ->
      _=lodash
      done()

  beforeEach ->
    sinon.stub(trak.io, 'identify')
    sinon.stub(trak.io, 'track')

  afterEach ->
    trak.io.track.restore() if trak.io.track.restore
    trak.io.identify.restore() if trak.io.identify.restore


  describe '#event_fired', ->

    value(form).equals_haml """
      %form#my_form.a_form.another_class{ action: \"/my_action/path\" }
        %input{ name: \"user[a_username_field]\", value: \"username_value\" }
        %input{ name: \"user[an_email_field]\", value: \"email_value\" }
        %input{ name: \"user[a_name_field]\", value: \"name_value\" }
        %input{ name: \"user[a_first_name_field]\", value: \"first_name_value\" }
        %input{ name: \"user[a_last_name_field]\", value: \"last_name_value\" }
        %input{ name: \"user[a_company_field]\", value: \"company_value\" }
        %input{ name: \"user[a_position_field]\", value: \"position_value\" }
        %input{ name: \"user[an_organisation_field]\", value: \"organisation_value\" }
        %input{ name: \"user[an_industry_field]\", value: \"industry_value\" }
        %input{ name: \"user[an_location_field]\", value: \"location_value\" }
        %input{ name: \"user[an_latlng_field]\", value: \"latlng_value\" }
        %input{ name: \"user[an_birthday_field]\", value: \"birthday_value\" }
    """

    it "passes callback along to trak.io.track", ->
      automagic().track.event_fired(form(), event(), callback(), {})
      trak.io.track.should.have.been.called
      trak.io.track.should.have.been.calledWith sinon.match.string, sinon.match.object, sinon.match.func
      trak.io.track.yield()
      callback().should.have.been.called

    it "fires a 'form_submitted' event", ->
      automagic().event_fired(event(), callback())
      trak.io.track.should.have.been.calledWith 'submitted_form', sinon.match.object, sinon.match.func


    it "sends id", ->
      automagic().event_fired(event(), callback())
      trak.io.track.should.have.been.calledWith sinon.match.string, sinon.match({ id: 'my_form'}), sinon.match.func

    it "sends classes", ->
      automagic().event_fired(event(), callback())
      trak.io.track.should.have.been.calledWith sinon.match.string, sinon.match({ class: ['a_form','another_class'] }), sinon.match.func

    it "sends action", ->
      automagic().event_fired(event(), callback())
      trak.io.track.should.have.been.calledWith sinon.match.string, sinon.match({ action: '/my_action/path' }), sinon.match.func

    it "sends referrer", ->
      automagic().event_fired(event(), callback())
      trak.io.track.should.have.been.calledWith sinon.match.string, sinon.match({ referrer: sinon.match(/\/test\/trak\.io\.automagic(\.min)?\.html/) }), sinon.match.func


    context "when a form with username and an additional field is submitted", ->

      value(form).equals_haml """
        %form.a_form
          %input{ name: \"user[username]\", value: \"username_value\" }
          %input{ name: \"user[an_organization_field]\", value: \"organisation_value\" }
      """

      it "fires a 'signed_up' event", ->
        automagic().event_fired(event(), callback())
        trak.io.track.should.have.been.calledWith 'signed_up', sinon.match.object, sinon.match.func


    context "when a form with username and password and an additional fields", ->

      value(form).equals_haml """
        %form.a_form
          %input{ name: \"user[username]\", value: \"username_value\" }
          %input{ name: \"user[pass]\", value: \"password_value\", type: \"password\" }
          %input{ name: \"user[confirm]\", value: \"password_value\", type: \"password\" }
          %input{ name: \"user[submit]\", value: \"Submit\", type: \"submit\" }
      """

      it "fires a 'signed_up' event", ->
        automagic().event_fired(event(), callback())
        trak.io.track.should.have.been.calledWith 'signed_up', sinon.match.object, sinon.match.func


    context "when a form with just and username and single password is submitted but 'sign up' in submit", ->

      value(form).equals_haml """
        %form.a_form
          %input{ name: \"user[username]\", value: \"username_value\" }
          %input{ name: \"user[pass]\", value: \"password_value\", type: \"password\" }
          %input{ name: \"user[remember]\", value: \"remember_value\", type: \"checkbox\" }
          %input{ name: \"user[submit]\", value: \"Sign up\", type: \"submit\" }
      """

      it "fires a 'signed_up' event", ->
        automagic().event_fired(event(), callback())
        trak.io.track.should.have.been.calledWith 'signed_up', sinon.match.object, sinon.match.func


    context "when a form with just and username and single password is submitted but 'Register' in submit", ->

      value(form).equals_haml """
        %form.a_form
          %input{ name: \"user[username]\", value: \"username_value\" }
          %input{ name: \"user[pass]\", value: \"password_value\", type: \"password\" }
          %input{ name: \"user[remember]\", value: \"remember_value\", type: \"checkbox\" }
          %input{ name: \"user[submit]\", value: \"Register\", type: \"submit\" }
      """

      it "fires a 'signed_up' event", ->
        automagic().event_fired(event(), callback())
        trak.io.track.should.have.been.calledWith 'signed_up', sinon.match.object, sinon.match.func


    context "when a form with just and username and single password is submitted but 'Create' in submit", ->

      value(form).equals_haml """
        %form.a_form
          %input{ name: \"user[username]\", value: \"username_value\" }
          %input{ name: \"user[pass]\", value: \"password_value\", type: \"password\" }
          %input{ name: \"user[submit]\", value: \"Create account\", type: \"submit\" }
      """

      it "fires a 'signed_up' event", ->
        automagic().event_fired(event(), callback())
        trak.io.track.should.have.been.calledWith 'signed_up', sinon.match.object, sinon.match.func


    context "when a form with just and username and single password is submitted", ->

      value(form).equals_haml """
        %form.a_form
          %input{ name: \"user[username]\", value: \"username_value\" }
          %input{ name: \"user[pass]\", value: \"password_value\", type: \"password\" }
          %input{ name: \"user[remember]\", value: \"remember_value\", type: \"checkbox\" }
          %input{ name: \"user[submit]\", value: \"Submit\", type: \"submit\" }
      """

      it "fires a 'signed_in' event", ->
        automagic().event_fired(event(), callback())
        trak.io.track.should.have.been.calledWith 'signed_in', sinon.match.object, sinon.match.func


    context "when a form with just email and single password is submitted", ->

      value(form).equals_haml """
        %form.a_form
          %input{ name: \"user[email]\", value: \"email_value\" }
          %input{ name: \"user[pass]\", value: \"password_value\", type: \"password\" }
          %input{ name: \"user[remember]\", value: \"remember_value\", type: \"checkbox\" }
          %input{ name: \"user[submit]\", value: \"Submit\", type: \"submit\" }
      """

      it "fires a 'signed_in' event", ->
        automagic().event_fired(event(), callback())
        trak.io.track.should.have.been.calledWith 'signed_in', sinon.match.object, sinon.match.func


    context "when a form with just email is submitted", ->

      value(form).equals_haml """
        %form.a_form
          %input{ name: \"user[email]\", value: \"email_value\" }
          %input{ name: \"user[submit]\", value: \"Submit\", type: \"submit\" }
      """

      it "fires a 'subscribed_with_email' event", ->
        automagic().event_fired(event(), callback())
        trak.io.track.should.have.been.calledWith 'subscribed_with_email', sinon.match.object, sinon.match.func

