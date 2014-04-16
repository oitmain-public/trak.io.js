describe 'Automagic', ->

  describe '#initialize', ->

    it 'should add a div', ->
      automagic = new Automagic()
      automagic.initialize()

      document.getElementById('trakio-automagic').should.not.equal.null
