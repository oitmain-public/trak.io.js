// Generated by IcedCoffeeScript 1.7.1-b
describe('trakio/automagic', function() {
  var automagic, automagic_initialized, automagic_options, event, form, second_form, _;
  _ = null;
  automagic = memoize().as(function() {
    return new Trak.Automagic();
  });
  automagic_initialized = memoize().as(function() {
    return automagic().initialize(automagic_options());
  });
  automagic_options = memoize().as(function() {
    return {};
  });
  form = memoize().as_haml("%form.my_form\n  %input");
  second_form = memoize().as_haml("%form.a_form\n  %input{type: \"text\"}\n  %input{type: \"submit\"}");
  event = memoize().as(function() {
    return new MockEvent('submit', form());
  });
  before(function(done) {
    return requirejs(['trakio/lodash'], function(lodash) {
      _ = lodash;
      return done();
    });
  });
  describe('#initialize', function() {
    it("initializes Automagic.Identify", function() {
      return automagic_initialized().identify.should.be.an["instanceof"](Trak.Automagic.Identify);
    });
    it("calls #page_ready if trak.io.page_ready_event_fired is true", function() {
      trak.io.page_ready_event_fired = true;
      sinon.stub(automagic(), 'page_ready');
      automagic().initialize();
      return automagic().page_ready.should.have.been.called;
    });
    return it("dosen't call #page_ready if trak.io.page_ready_event_fired is false", function() {
      trak.io.page_ready_event_fired = false;
      sinon.stub(automagic(), 'page_ready');
      automagic().initialize();
      return automagic().page_ready.should.not.have.been.called;
    });
  });
  describe('#page_ready', function() {
    it("adds data-trakio-automagic attribute to body", function() {
      automagic_initialized().page_ready();
      return document.body.hasAttribute('data-trakio-automagic').should.eql(true);
    });
    it("calls #bind_events", function() {
      sinon.stub(automagic(), 'bind_events');
      automagic_initialized().page_ready();
      return automagic().bind_events.should.have.been.called;
    });
    context("when bind events is false", function() {
      value(automagic_options).equals({
        bind_events: false
      });
      return it("doesn't call #bind_events", function() {
        sinon.stub(automagic(), 'bind_events');
        automagic_initialized().page_ready();
        return automagic().bind_events.should.not.have.been.called;
      });
    });
    return it("calls trakio/automagic/identify#page_ready", function() {
      sinon.stub(automagic_initialized().identify, 'page_ready');
      automagic().page_ready();
      return automagic().identify.page_ready.should.have.been.called;
    });
  });
  describe('#bind_events', function() {
    afterEach(function() {
      if (document.body.addEventListener.restore) {
        return document.body.addEventListener.restore();
      }
    });
    context("when submit bubbles", function() {
      return it("binds submit on body", function() {
        var addEventListener;
        addEventListener = sinon.stub(document.body, 'addEventListener');
        sinon.stub(automagic(), 'submit_bubbles').returns(true);
        automagic_initialized().bind_events();
        addEventListener.should.have.been.calledOnce;
        addEventListener.should.have.been.calledWith('submit');
        return addEventListener.restore();
      });
    });
    return context("when submit does not bubble", function() {
      return it("binds click and keypress on body", function() {
        var addEventListener;
        addEventListener = sinon.stub(document.body, 'addEventListener');
        sinon.stub(automagic(), 'submit_bubbles').returns(false);
        automagic_initialized().bind_events();
        addEventListener.should.have.been.calledTwice;
        addEventListener.should.have.been.calledWith('click');
        addEventListener.should.have.been.calledWith('keypress');
        return addEventListener.restore();
      });
    });
  });
  describe('#emulated_form_submitted', function() {
    context("when it's triggered by a click", function() {
      return it("should call form_submitted if it's a submit button", function() {
        var stub, submit, _event;
        stub = sinon.stub(automagic(), 'form_submitted').returns(false);
        second_form();
        submit = $('input[type=submit]')[0];
        _event = new MockEvent('click', submit);
        automagic_initialized().emulated_form_submitted(_event);
        stub.should.have.been.called;
        return stub.restore();
      });
    });
    return context("when it's triggered by a keypress", function() {
      return it("should call form_submitted if it's an enter key", function() {
        var stub, text, _event;
        stub = sinon.stub(automagic(), 'form_submitted').returns(false);
        second_form();
        text = $('input[type=text]')[0];
        _event = new MockEvent('keypress', text, {
          keyCode: 13
        });
        automagic_initialized().emulated_form_submitted(_event);
        stub.should.have.been.called;
        return stub.restore();
      });
    });
  });
  return describe('#form_submitted', function() {
    return it("calls trakio/automagic/identify#form_submitted", function() {
      sinon.stub(automagic_initialized().identify, 'form_submitted').returns(false);
      automagic().form_submitted(event());
      return automagic().identify.form_submitted.should.have.been.calledWith(event());
    });
  });
});
