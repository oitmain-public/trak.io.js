describe 'Automagic', ->

  afterEach ->
    $('form').remove()

  describe '#create_hooks', ->

    it 'should add data-automagic attribute to body', ->
      automagic = new Automagic()
      automagic.initialize() # calls create_hooks

      document.body.hasAttribute('data-automagic').should.eql true

    it 'should call hook on each form', ->
      form = document.createElement('form')
      field = document.createElement('input')

      form.appendChild(field)
      document.body.appendChild(form)

      automagic = new Automagic()
      hook = sinon.stub(automagic, 'hook')
      automagic.initialize()

      hook.should.have.been.calledWith(form)

  describe '#hook', ->

    it 'should add a callback to the form', ->
      form = document.createElement('form')
      addEventListener = sinon.stub(form, 'addEventListener')

      field = document.createElement('input')

      form.appendChild(field)
      document.body.appendChild(form)

      automagic = new Automagic()
      automagic.initialize()

      addEventListener.should.have.been.calledWith('submit')

    describe 'the callback when the form is submitted', ->

      it 'should call anything binded to form.onsubmit', ->
        callback = sinon.spy (event) ->
          event.preventDefault()

        form = document.createElement('form')
        form.id = 'callback-1'
        form.onsubmit = callback
        field = document.createElement('input')
        field.name = 'name'
        field.value = 'Tobie'
        form.appendChild(field)

        document.body.appendChild(form)

        automagic = new Automagic()
        automagic.initialize()

        $('#callback-1').submit()

        callback.should.have.been.called


  describe '#extract_data', ->

    it 'should extract the data', ->
      automagic = new Automagic()
      automagic.initialize()

      form = document.createElement('form')

      field_1 = document.createElement('input')
      field_1.type = 'text'
      field_1.name = 'name'
      field_1.value = 'Tobie'

      form.appendChild(field_1)

      field_2 = document.createElement('textarea')
      field_2.name = 'location'
      field_2.value = 'England'
      form.appendChild(field_2)

      automagic.extract_data(form).should.eql
        name: 'Tobie',
        location: 'England'
