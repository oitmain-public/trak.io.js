// Generated by IcedCoffeeScript 1.4.0c

requirejs(['exceptions'], function(Exceptions) {
  return describe('Trak', function() {
    before_each(function() {
      sinon.stub(trak.io, 'call');
      sinon.stub(trak.io, 'distinct_id').returns('default_distinct_id');
      sinon.stub(trak.io, 'context').returns({
        "default": 'context',
        override: 'override'
      });
      return sinon.stub(trak.io, 'channel').returns('default_channel');
    });
    after_each(function() {
      trak.io.call.restore();
      trak.io.distinct_id.restore();
      trak.io.context.restore();
      return trak.io.channel.restore();
    });
    describe('#track()', function() {
      return it("raises Exceptions.MissingParameter", function() {
        return expect(function() {
          return trak.io.track();
        }).to["throw"](Exceptions.MissingParameter);
      });
    });
    describe('#track(event)', function() {
      return it("calls #call", function() {
        trak.io.track('my_event');
        return trak.io.call.should.have.been.calledWith('track', {
          data: {
            distinct_id: 'default_distinct_id',
            event: 'my_event',
            channel: 'default_channel',
            context: {
              "default": 'context',
              override: 'override'
            },
            properties: {}
          }
        }, null);
      });
    });
    describe('#track(event, properties)', function() {
      return it("calls #call", function() {
        var properties;
        properties = {
          foo: 'bar'
        };
        trak.io.track('my_event', properties);
        return trak.io.call.should.have.been.calledWith('track', {
          data: {
            distinct_id: 'default_distinct_id',
            event: 'my_event',
            channel: 'default_channel',
            context: {
              "default": 'context',
              override: 'override'
            },
            properties: properties
          }
        }, null);
      });
    });
    describe('#track(event, properties, context)', function() {
      it("calls #call merging contexts", function() {
        var context, properties;
        properties = {
          my: 'properties'
        };
        context = {
          my: 'context',
          override: 'overriden'
        };
        trak.io.track('my_event', properties, context);
        return trak.io.call.should.have.been.calledWith('track', {
          data: {
            distinct_id: 'default_distinct_id',
            event: 'my_event',
            channel: 'default_channel',
            context: {
              "default": 'context',
              override: 'overriden',
              my: 'context'
            },
            properties: properties
          }
        }, null);
      });
      return it("doesn't change trak.io.context()", function() {
        var context, properties;
        properties = {
          my: 'properties'
        };
        context = {
          my: 'context'
        };
        trak.io.track('my_event', properties, context);
        return trak.io.context.should.have.been.calledWithExactly();
      });
    });
    describe('#track(event, channel)', function() {
      return it("calls #call", function() {
        trak.io.track('my_event', 'my_channel');
        return trak.io.call.should.have.been.calledWith('track', {
          data: {
            distinct_id: 'default_distinct_id',
            event: 'my_event',
            channel: 'my_channel',
            context: {
              "default": 'context',
              override: 'override'
            },
            properties: {}
          }
        }, null);
      });
    });
    describe('#track(event, channel, properties)', function() {
      it("calls #call", function() {
        var properties;
        properties = {
          foo: 'bar'
        };
        trak.io.track('my_event', 'my_channel', properties);
        return trak.io.call.should.have.been.calledWith('track', {
          data: {
            distinct_id: 'default_distinct_id',
            event: 'my_event',
            channel: 'my_channel',
            context: {
              "default": 'context',
              override: 'override'
            },
            properties: properties
          }
        }, null);
      });
      return it("doesn't change trak.io.channel()", function() {
        var properties;
        properties = {
          foo: 'bar'
        };
        trak.io.track('my_event', 'my_channel', properties);
        return trak.io.channel.should.have.been.calledWithExactly();
      });
    });
    describe('#track(event, channel, properties, context)', function() {
      it("calls #call merging contexts", function() {
        var context, properties;
        properties = {
          my: 'properties'
        };
        context = {
          my: 'context',
          override: 'overriden'
        };
        trak.io.track('my_event', 'my_channel', properties, context);
        return trak.io.call.should.have.been.calledWith('track', {
          data: {
            distinct_id: 'default_distinct_id',
            event: 'my_event',
            channel: 'my_channel',
            context: {
              "default": 'context',
              override: 'overriden',
              my: 'context'
            },
            properties: properties
          }
        }, null);
      });
      it("doesn't change trak.io.context()", function() {
        var context, properties;
        properties = {
          my: 'properties'
        };
        context = {
          my: 'context'
        };
        trak.io.track('my_event', 'my_channel', properties, context);
        return trak.io.context.should.have.been.calledWithExactly();
      });
      return it("doesn't change trak.io.channel()", function() {
        var context, properties;
        properties = {
          foo: 'bar'
        };
        context = {
          my: 'context'
        };
        trak.io.track('my_event', 'my_channel', properties, context);
        return trak.io.channel.should.have.been.calledWithExactly();
      });
    });
    describe('#track(distinct_id, event, channel)', function() {
      it("calls #call", function() {
        trak.io.track('my_distinct_id', 'my_event', 'my_channel');
        return trak.io.call.should.have.been.calledWith('track', {
          data: {
            distinct_id: 'my_distinct_id',
            event: 'my_event',
            channel: 'my_channel',
            context: {
              "default": 'context',
              override: 'override'
            },
            properties: {}
          }
        }, null);
      });
      it("doesn't change trak.io.distinct_id()", function() {
        trak.io.track('my_distinct_id', 'my_event', 'my_channel');
        return trak.io.distinct_id.should.have.been.calledWithExactly();
      });
      return it("doesn't change trak.io.channel()", function() {
        trak.io.track('my_distinct_id', 'my_event', 'my_channel');
        return trak.io.channel.should.have.been.calledWithExactly();
      });
    });
    describe('#track(distinct_id, event, channel, properties)', function() {
      it("calls #call", function() {
        var properties;
        properties = {
          my: 'properties'
        };
        trak.io.track('my_distinct_id', 'my_event', 'my_channel', properties);
        return trak.io.call.should.have.been.calledWith('track', {
          data: {
            distinct_id: 'my_distinct_id',
            event: 'my_event',
            channel: 'my_channel',
            context: {
              "default": 'context',
              override: 'override'
            },
            properties: properties
          }
        }, null);
      });
      it("doesn't change trak.io.distinct_id()", function() {
        var properties;
        properties = {
          my: 'properties'
        };
        trak.io.track('my_distinct_id', 'my_event', 'my_channel', properties);
        return trak.io.distinct_id.should.have.been.calledWithExactly();
      });
      return it("doesn't change trak.io.channel()", function() {
        var properties;
        properties = {
          my: 'properties'
        };
        trak.io.track('my_distinct_id', 'my_event', 'my_channel', properties);
        return trak.io.channel.should.have.been.calledWithExactly();
      });
    });
    return describe('#track(distinct_id, event, channel, properties, context)', function() {
      it("calls #call merging contexts", function() {
        var context, properties;
        properties = {
          my: 'properties'
        };
        context = {
          my: 'context',
          override: 'overriden'
        };
        trak.io.track('my_distinct_id', 'my_event', 'my_channel', properties, context);
        return trak.io.call.should.have.been.calledWith('track', {
          data: {
            distinct_id: 'my_distinct_id',
            event: 'my_event',
            channel: 'my_channel',
            context: {
              "default": 'context',
              override: 'overriden',
              my: 'context'
            },
            properties: properties
          }
        }, null);
      });
      it("doesn't change trak.io.distinct_id()", function() {
        var context, properties;
        properties = {
          my: 'properties'
        };
        context = {
          my: 'context'
        };
        trak.io.track('my_distinct_id', 'my_event', 'my_channel', properties, context);
        return trak.io.distinct_id.should.have.been.calledWithExactly();
      });
      it("doesn't change trak.io.channel()", function() {
        var context, properties;
        properties = {
          my: 'properties'
        };
        context = {
          my: 'context'
        };
        trak.io.track('my_distinct_id', 'my_event', 'my_channel', properties, context);
        return trak.io.channel.should.have.been.calledWithExactly();
      });
      return it("doesn't change trak.io.context()", function() {
        var context, properties;
        properties = {
          my: 'properties'
        };
        context = {
          my: 'context'
        };
        trak.io.track('my_distinct_id', 'my_event', 'my_channel', properties, context);
        return trak.io.context.should.have.been.calledWithExactly();
      });
    });
  });
});
