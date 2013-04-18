requirejs ['exceptions'], (Exceptions) ->

  describe  'Trak', ->

    before ->
      sinon.stub(trak.io, 'track')
      sinon.stub(trak.io, 'url').returns('page_url')
      sinon.stub(trak.io, 'page_title').returns('A page title')

    after ->
      trak.io.track.restore()
      trak.io.page_title.restore()
      trak.io.url.restore()

    describe '#page_view()', ->

      it "should call #track", ->
        trak.io.page_view()
        trak.io.track.should.have.been.calledWith('page_view', { url: 'page_url', page_title: 'A page title' })


    describe '#page_view(url)', ->

      it "should call #track", ->
        trak.io.page_view('custom_page_url')
        trak.io.track.should.have.been.calledWith('page_view', { url: 'custom_page_url', page_title: 'A page title' })


    describe '#page_view(url, title)', ->

      it "should call #track", ->
        trak.io.page_view('custom_page_url', 'custom page title')
        trak.io.track.should.have.been.calledWith('page_view', { url: 'custom_page_url', page_title: 'custom page title' })


