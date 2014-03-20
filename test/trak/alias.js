// Generated by IcedCoffeeScript 1.7.1-b
requirejs([], function() {
  return describe('Trak', function() {
    beforeEach(function() {
      trak.io._distinct_id = 'old_distinct_id';
      return sinon.stub(trak.io, 'call');
    });
    afterEach(function() {
      trak.io.call.restore();
      return trak.io._distinct_id = null;
    });
    describe('#alias()', function() {
      return it("raises Exceptions.MissingParameter", function() {
        return expect(function() {
          return trak.io.alias();
        }).to["throw"](trak.Exceptions.MissingParameter);
      });
    });
    describe('#alias(alias)', function() {
      it("calls #call", function() {
        trak.io._distinct_id = 'old_distinct_id';
        trak.io.alias('my_alias');
        return trak.io.call.should.have.been.calledWith('alias', {
          data: {
            distinct_id: 'old_distinct_id',
            alias: 'my_alias'
          }
        });
      });
      it("sets current distinct_id to the alias", function() {
        trak.io._distinct_id = 'old_distinct_id';
        trak.io.alias('my_alias');
        trak.io.distinct_id().should.equal('my_alias');
        return cookie.get("_trak_" + (trak.io.api_token()) + "_id").should.equal('my_alias');
      });
      it("doesn't make a call if the alias is the same as the current distinct_id", function() {
        trak.io._distinct_id = 'bbb';
        trak.io.alias('bbb');
        return trak.io.call.should.not.have.been.called;
      });
      return it("takes an numerical value for id", function() {
        trak.io.alias(1234);
        return trak.io._distinct_id.should.eq('1234');
      });
    });
    describe('#alias(alias, false)', function() {
      it("calls #call", function() {
        trak.io.alias('my_alias');
        return trak.io.call.should.have.been.calledWith('alias', {
          data: {
            distinct_id: 'old_distinct_id',
            alias: 'my_alias'
          }
        });
      });
      return it("doesn't set current distinct_id to the alias", function() {
        var previous_id;
        previous_id = trak.io.distinct_id();
        trak.io.alias('my_alias', false);
        trak.io.distinct_id().should.equal(previous_id);
        return cookie.get("_trak_" + (trak.io.api_token()) + "_id").should.equal(previous_id);
      });
    });
    describe('#alias(distinct_id, alias)', function() {
      it("calls #call", function() {
        trak.io.alias('custom_distinct_id', 'my_alias');
        return trak.io.call.should.have.been.calledWith('alias', {
          data: {
            distinct_id: 'custom_distinct_id',
            alias: 'my_alias'
          }
        });
      });
      it("doesn't set current distinct_id to the alias", function() {
        var previous_id;
        previous_id = trak.io.distinct_id();
        trak.io.alias('custom_distinct_id', 'my_alias');
        trak.io.distinct_id().should.equal(previous_id);
        return cookie.get("_trak_" + (trak.io.api_token()) + "_id").should.equal(previous_id);
      });
      return it("doesn't make a call if the alias is the same as the distinct_id", function() {
        trak.io.alias('aaa', 'aaa');
        return trak.io.call.should.not.have.been.called;
      });
    });
    return describe('#alias(distinct_id, alias, callback)', function() {
      return it("still calls callback if alias is the same as the distinct_id", function() {
        var callback;
        callback = sinon.spy();
        trak.io.alias('aaa', 'aaa', callback);
        return callback.should.have.been.calledWith({
          status: 'unnecessary'
        });
      });
    });
  });
});
