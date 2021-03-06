// Generated by IcedCoffeeScript 1.7.1-b
describe('Trak', function() {
  beforeEach(function() {
    sinon.stub(trak.io, 'call');
    trak.io.distinct_id('my_distinct_id');
    trak.io.company_id('company_id');
    return trak.io.should_track(true);
  });
  afterEach(function() {
    return trak.io.call.restore();
  });
  describe('#company(properties)', function() {
    it("calls #call", function() {
      var properties;
      properties = {
        foo: 'bar'
      };
      trak.io.company_id('company_id');
      trak.io.company(properties);
      return trak.io.call.should.have.been.calledWith('company', {
        data: {
          company_id: trak.io.company_id(),
          properties: properties,
          people_distinct_ids: ["my_distinct_id"]
        }
      });
    });
    return context("when company_id has not been provided", function() {
      return it("raises Exceptions.MissingParameter", function() {
        return expect(function() {
          var trakio;
          trakio = new Trak();
          sinon.stub(trakio, 'call');
          trakio.initialize('api_token_value_2');
          trakio.sign_out();
          return trakio.company({
            foo: 'bar'
          });
        }).to["throw"](trak.Exceptions.MissingParameter);
      });
    });
  });
  describe('#company(properties, callback)', function() {
    return it("executes callback after company responds", function() {
      var callback, properties;
      properties = {
        foo: 'bar'
      };
      callback = sinon.spy();
      trak.io.company(properties, callback);
      return trak.io.call.should.have.been.calledWith('company', {
        data: {
          company_id: trak.io.company_id(),
          properties: properties,
          people_distinct_ids: ["my_distinct_id"]
        }
      }, callback);
    });
  });
  describe('#company(company_id)', function() {
    return context("when distinct_id is set", function() {
      return it("sends it in the people_distinct_ids parameter", function() {
        var trakio;
        trakio = new Trak();
        sinon.stub(trakio, 'call');
        trakio.company_id('my_company_id');
        trakio.distinct_id('my_distinct_id');
        trakio.company();
        return trakio.call.should.have.been.calledWith('company', {
          data: {
            company_id: 'my_company_id',
            people_distinct_ids: ['my_distinct_id']
          }
        });
      });
    });
  });
  describe('#company(company_id, properties)', function() {
    it("calls #call", function() {
      var properties;
      properties = {
        foo: 'bar'
      };
      trak.io.company('my_company_id', properties);
      trak.io.call.should.have.been.called;
      trak.io.call.getCall(0).args[0].should.eql('company');
      return trak.io.call.getCall(0).args[1].should.eql({
        data: {
          company_id: 'my_company_id',
          people_distinct_ids: ["my_distinct_id"],
          properties: properties
        }
      });
    });
    return it("sets the company_id", function() {
      var properties;
      properties = {
        foo: 'bar'
      };
      trak.io.company('my_company_id', properties);
      trak.io.company_id().should.equal('my_company_id');
      return cookie.get("_trak_" + (trak.io.api_token()) + "_company_id").should.equal('my_company_id');
    });
  });
  return describe('#company(company_id, properties, callback)', function() {
    return it("executes callback with company data after company responds", function() {
      var callback, properties;
      trak.io.company_id('my_company_id');
      callback = sinon.spy();
      properties = {
        foo: 'bar'
      };
      trak.io.company('my_company_id', properties, callback);
      return trak.io.call.should.have.been.calledWith('company', {
        data: {
          company_id: 'my_company_id',
          properties: {
            foo: "bar"
          },
          people_distinct_ids: ["my_distinct_id"]
        }
      }, callback);
    });
  });
});
