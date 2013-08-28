// Generated by IcedCoffeeScript 1.4.0c

requirejs([], function() {
  return describe('Trak', function() {
    beforeEach(function() {
      return sinon.stub(trak.io, 'call');
    });
    afterEach(function() {
      trak.io.distinct_id('another_distinct_id');
      return trak.io.call.restore();
    });
    describe('#identify(properties)', function() {
      return it("calls #call", function() {
        var properties;
        properties = {
          foo: 'bar'
        };
        trak.io.identify(properties);
        return trak.io.call.should.have.been.calledWith('identify', {
          data: {
            distinct_id: trak.io.distinct_id(),
            properties: properties
          }
        });
      });
    });
    describe('#identify(properties, callback)', function() {
      return it("executes callback after identify responds", function() {
        var callback, properties;
        sinon.stub(trak.io, 'alias');
        properties = {
          foo: 'bar'
        };
        callback = sinon.spy();
        trak.io.identify(properties, callback);
        trak.io.call.should.have.been.calledWith('identify', {
          data: {
            distinct_id: trak.io.distinct_id(),
            properties: properties
          }
        }, callback);
        trak.io.alias.should.not.have.been.called;
        return trak.io.alias.restore();
      });
    });
    describe('#identify(distinct_id)', function() {
      beforeEach(function() {
        return sinon.stub(trak.io, 'alias');
      });
      afterEach(function() {
        return trak.io.alias.restore();
      });
      it("doesn't bother with #call", function() {
        trak.io.identify('my_distinct_id');
        return trak.io.call.should.not.have.been.calledWith('identify');
      });
      return it("calls alias with the distinct_id", function() {
        trak.io.identify('my_distinct_id');
        return trak.io.alias.should.have.been.calledWith('my_distinct_id');
      });
    });
    describe('#identify(distinct_id, callback)', function() {
      return it("executes callback after alias responds", function() {
        var callback;
        sinon.stub(trak.io, 'alias', function(distinct_id, callback) {
          distinct_id.should.equal('my_distinct_id');
          return callback({
            status: 'success'
          });
        });
        callback = sinon.spy();
        trak.io.identify('my_distinct_id', callback);
        callback.should.have.been.calledWith({
          status: 'success'
        });
        return trak.io.alias.restore();
      });
    });
    describe('#identify(distinct_id, properties)', function() {
      it("calls #call", function() {
        var properties;
        properties = {
          foo: 'bar'
        };
        trak.io.identify('my_distinct_id', properties);
        trak.io.call.should.have.been.called;
        trak.io.call.getCall(0).args[0].should.equal('alias');
        trak.io.call.getCall(0).args[0].should.eql('alias');
        trak.io.call.getCall(0).args[1].should.eql({
          data: {
            distinct_id: 'another_distinct_id',
            alias: 'my_distinct_id'
          }
        });
        trak.io.call.getCall(0).args[2]();
        trak.io.call.getCall(1).args[0].should.eql('identify');
        return trak.io.call.getCall(1).args[1].should.eql({
          data: {
            distinct_id: 'my_distinct_id',
            properties: properties
          }
        });
      });
      return it("sets the distinct_id", function() {
        var properties;
        properties = {
          foo: 'bar'
        };
        trak.io.identify('my_distinct_id', properties);
        trak.io.distinct_id().should.equal('my_distinct_id');
        return cookie.get("_trak_" + (trak.io.api_token()) + "_id").should.equal('my_distinct_id');
      });
    });
    return describe('#identify(distinct_id, properties, callback)', function() {
      it("executes callback with alias data after alias and identify responses", function() {
        var callback, properties;
        sinon.stub(trak.io, 'alias', function(distinct_id, callback) {
          distinct_id.should.equal('my_distinct_id');
          return callback();
        });
        callback = sinon.spy();
        properties = {
          foo: 'bar'
        };
        trak.io.identify('my_distinct_id', properties, callback);
        trak.io.call.should.have.been.calledWith('identify', {
          data: {
            distinct_id: 'my_distinct_id',
            properties: {
              foo: "bar"
            }
          }
        }, callback);
        return trak.io.alias.restore();
      });
      return it("executes callback with identify data after identify response and unnecessary alias", function() {
        var callback, properties;
        trak.io.distinct_id('my_distinct_id');
        callback = sinon.spy();
        properties = {
          foo: 'bar'
        };
        trak.io.identify('my_distinct_id', properties, callback);
        return trak.io.call.should.have.been.calledWith('identify', {
          data: {
            distinct_id: 'my_distinct_id',
            properties: {
              foo: "bar"
            }
          }
        }, callback);
      });
    });
  });
});
