describe 'Automagic', ->

  describe '#initialize', ->

    it 'should add data-automagic attribute to body', ->
      automagic = new Automagic()
      automagic.initialize()

      document.body.hasAttribute('data-automagic').should.eql true
