describe 'trakio/automagic/identify', ->

  _
  form = memoized().as_haml """
    %form.a_form
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
    trak.io.identify.restore() if trak.io.identify.restore
    trak.io.track.restore() if trak.io.track.restore

  describe '#event_fired', ->

    it "passes callback along to trak.io.identify", ->
      automagic().identify.event_fired(form(), event(), callback(), {})
      trak.io.identify.should.have.been.calledWith sinon.match.string, sinon.match.object, sinon.match.func
      trak.io.identify.yield()
      callback().should.have.been.called


    it "sends all values according to the property map", ->
      automagic().event_fired(event(), ()->)
      trak.io.identify.should.have.been.calledWith 'username_value',
        username: "username_value"
        name: "name_value"
        first_name: "first_name_value"
        last_name: "last_name_value"
        email: "email_value"
        position: "position_value"
        company: "company_value"
        organization: "organisation_value"
        industry: "industry_value"
        location: "location_value"
        latlng: "latlng_value"
        birthday: "birthday_value"


    context "when using the US english spelling of organisation", ->

      value(form).equals_haml """
        %form.a_form
          %input{ name: \"user[username]\", value: \"username_value\" }
          %input{ name: \"user[an_organization_field]\", value: \"organisation_value\" }
      """

      it "sends all values according to the property map", ->
        automagic().event_fired(event(), ()->)
        trak.io.identify.should.have.been.calledWith 'username_value',
          username: 'username_value'
          organization: 'organisation_value'


    context "when using latlon", ->

      value(form).equals_haml """
        %form.a_form
          %input{ name: \"user[username]\", value: \"username_value\" }
          %input{ name: \"user[a_latlon_field]\", value: \"latlon_value\" }
      """

      it "sends all values according to the property map", ->
        automagic().event_fired(event(), ()->)
        trak.io.identify.should.have.been.calledWith 'username_value',
          username: 'username_value'
          latlng: "latlon_value"


    context "when using dob", ->

      value(form).equals_haml """
        %form.a_form
          %input{ name: \"user[username]\", value: \"username_value\" }
          %input{ name: \"user[a_dob_field]\", value: \"dob_value\" }
      """

      it "sends all values according to the property map", ->
        automagic().event_fired(event(), ()->)
        trak.io.identify.should.have.been.calledWith 'username_value',
          username: 'username_value'
          birthday: "dob_value"


    context "when using date of birth", ->

      value(form).equals_haml """
        %form.a_form
          %input{ name: \"user[username]\", value: \"username_value\" }
          %input{ name: \"user[a_date_ofbirth_field]\", value: \"date_of_birth_value\" }
      """

      it "sends all values according to the property map", ->
        automagic().event_fired(event(), ()->)
        trak.io.identify.should.have.been.calledWith('username_value',
          username: 'username_value'
          birthday: "date_of_birth_value"
        )


    context "when using fname, lname", ->

      value(form).equals_haml """
        %form.a_form
          %input{ name: \"user[username]\", value: \"username_value\" }
          %input{ name: \"user[fname]\", value: \"first_name_value\" }
          %input{ name: \"user[lname]\", value: \"last_name_value\" }
          %input{ name: \"user[f__name]\", value: \"not_first_name_value\" }
          %input{ name: \"user[l__name]\", value: \"not_last_name_value\" }
      """

      it "sends all values according to the property map", ->
        automagic().event_fired(event(), ()->)
        trak.io.identify.should.have.been.calledWith('username_value',
          username: 'username_value'
          first_name: "first_name_value"
          last_name: "last_name_value"
          name: "not_last_name_value"
        )

    it "does not send value for fields that are excluded based on excluded_field_selector", ->
      value(form).equals_haml_now """
        %form.a_form
          %input{ name: \"user[username]\", value: \"username_value\" }
          %input{ name: \"user[name]\", value: \"password_value\", type: \"password\" }
      """
      automagic().event_fired(event(), ()->)
      trak.io.identify.should.have.been.calledWith 'username_value',
        username: "username_value"


    context "when form matches any value for has_any_fields", ->

      value(automagic_options).equals -> {
        identify:
          has_any_fields: ['my_field','another_field']
          property_map:
            email: /email/
            my_field: /my_field/
            another_field: /another_field/
      }
      value(form).equals_haml """
        %form.a_form
          %input{ name: \"user[email]\", value: \"email_value\" }
          %input{ name: \"user[my_field]\", value: \"my_field_value\" }
      """

      it "calls trak.io.identify", ->
        automagic().event_fired(event(), ()->)
        trak.io.identify.should.have.been.calledWith 'email_value',
          email: 'email_value'
          my_field: 'my_field_value'


    context "when form doesn't match any values for has_any_fields", ->

      value(automagic_options).equals -> {
        identify:
          has_any_fields: ['my_field','another_field']
          property_map:
            email: /email/
            my_field: /my_field/
            another_field: /another_field/
      }
      value(form).equals_haml """
        %form.a_form
          %input{ name: \"user[email]\", value: \"email_value\" }
          %input{ name: \"user[not_a_field]\", value: \"my_field_value\" }
      """

      it "doesn't call trak.io.identify", ->
        automagic().event_fired(event(), callback())
        trak.io.identify.should.not.have.been.called

      it "calls the callback", ->
        automagic().event_fired(event(), callback())
        trak.io.track.yield()
        trak.io.track.yield()
        callback().should.have.been.called


    context "when form matches all values for has_all_fields", ->

      value(automagic_options).equals -> {
        identify:
          has_any_fields: ['my_field','another_field']
          has_all_fields: ['yet_another_field','last_one']
          property_map:
            email: /email/
            my_field: /my_field/
            another_field: /^(?!yet_another_field)another_field/
            yet_another_field: /yet_another_field/
            last_one: /last_one/
      }
      value(form).equals_haml """
        %form.a_form
          %input{ name: "user[email]", value: "email_value" }
          %input{ name: "user[my_field]", value: "my_field_value" }
          %input{ name: "user[yet_another_field]", value: "yet_another_field_value" }
          %input{ name: "user[last_one]", value: "last_one_value" }
      """

      it "calls trak.io.identify", ->
        automagic().event_fired(event(), ()->)
        trak.io.identify.should.have.been.calledWith 'email_value',
          email: 'email_value'
          my_field: 'my_field_value'
          yet_another_field: 'yet_another_field_value'
          last_one: 'last_one_value'


    context "when form doesn't match all values for has_all_fields", ->

      value(automagic_options).equals -> {
        identify:
          has_any_fields: ['my_field','another_field']
          has_all_fields: ['yet_another_field','last_one']
          property_map:
            email: /email/
            my_field: /my_field/
            another_field: /another_field/
            yet_another_field: /yet_another_field/
            last_one: /last_one/
      }
      value(form).equals_haml """
        %form.a_form
          %input{ name: "user[email]", value: "email_value" }
          %input{ name: "user[my_field]", value: "my_field_value" }
          %input{ name: "user[yet_another_field]", value: "yet_another_field_value" }
      """

      it "doesn't call trak.io.identify", ->
        automagic().event_fired(event(), callback())
        trak.io.identify.should.not.have.been.called

      it "calls the callback", ->
        automagic().event_fired(event(), callback())
        trak.io.track.yield()
        trak.io.track.yield()
        callback().should.have.been.called


    context "when form provides a matching distinct_id field", ->

      value(form).equals_haml """
        %form.a_form
          %input{ name: \"user[username]\", value: \"username_value\" }
          %input{ name: \"user[email]\", value: \"email_value\" }
      """

      it "calls trak.io.identify with the value", ->
        automagic().event_fired(event(), ()->)
        trak.io.identify.should.have.been.calledWith 'username_value',
          email: 'email_value'
          username: 'username_value'


    context "when form provides a matching secondary distinct_id field", ->
      value(form).equals_haml """
        %form.a_form
          %input{ name: \"user[name]\", value: \"name_value\" }
          %input{ name: \"user[email]\", value: \"email_value\" }
      """

      it "calls trak.io.identify with the value", ->
        automagic().event_fired(event(), ()->)
        trak.io.identify.should.have.been.calledWith 'email_value',
          email: 'email_value'
          name: 'name_value'


    context "when form doesn't provied a distinct_id", ->

      value(form).equals_haml """
        %form.a_form
          %input{ name: \"user[name]\", value: \"name_value\" }
      """

      afterEach ()->
        trak.io.distinct_id.restore()

      it "calls trak.io.identify with the auto generaterd distinct_id", ->
        sinon.stub(trak.io, 'distinct_id').returns('auto_distinct_id')
        automagic().event_fired(event(), ()->)
        trak.io.identify.should.have.been.calledWith 'auto_distinct_id',
          name: 'name_value'


    context "when form matches the identify form selector", ->

      value(automagic_options).equals -> { identify: { selector: '.a_form' } }

      it "calls trak.io.identify", ->
        automagic().event_fired(event(), ()->)
        trak.io.identify.should.have.been.called


    context "when a form does not match the identify form selector", ->

      value(automagic_options).equals -> { identify: { selector: '.my_form' } }

      it "does not call trak.io.identify", ->
        automagic().event_fired(event(), callback())
        trak.io.identify.should.not.have.been.called

      it "calls the callback", ->
        automagic().event_fired(event(), callback())
        trak.io.track.yield()
        trak.io.track.yield()
        callback().should.have.been.called


