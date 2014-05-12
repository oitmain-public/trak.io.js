// Generated by IcedCoffeeScript 1.7.1-b
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(['trakio/lodash', 'trakio/automagic/identify'], function(_, Identify) {
  var Automagic, instance, _i, _len, _ref, _results;
  Automagic = (function() {
    function Automagic() {
      this.form_submitted = __bind(this.form_submitted, this);
      this.bind_to_form_submit = __bind(this.bind_to_form_submit, this);
      this.bind_events = __bind(this.bind_events, this);
      this.page_ready = __bind(this.page_ready, this);
      this.page_body = __bind(this.page_body, this);
      this.merge_options = __bind(this.merge_options, this);
    }

    Automagic.prototype.default_options = {
      test_hooks: [],
      bind_events: true,
      form_selector: 'form',
      identify: {
        form_selector: 'form',
        excluded_field_selector: '[type=password]',
        property_map: {
          username: /.*username.*/,
          name: /^(?!(.*first.*|.*last.*|.*user|.*f.?|.*l.?)name).*name.*/,
          first_name: /.*(first.*|f.?)name.*/,
          last_name: /.*(last.*|l.?)name.*/,
          email: /.*email.*/,
          position: /.*position.*/,
          company: /.*company.*/,
          organization: /.*organi(z|s)ation.*/,
          industry: /.*industry.*/,
          location: /.*location.*/,
          latlng: /.*latl(ng|on).*/,
          birthday: /.*(birthday|dob|date.*of.*birth).*/
        },
        has_any_fields: ['username', 'name', 'first_name', 'last_name', 'email'],
        has_all_fields: [],
        distinct_ids: ['username', 'email']
      }
    };

    Automagic.prototype.initialize = function(options) {
      if (options == null) {
        options = {};
      }
      try {
        this.options = _.cloneDeep(this.default_options);
        _.merge(this.options, options, this.merge_options);
        this.identify = new Identify();
        this.identify.initialize(this, this.options.identify);
        if (trak.io.page_ready_event_fired) {
          this.page_ready();
        }
        return this;
      } catch (_error) {

      }
    };

    Automagic.prototype.merge_options = function(a, b) {
      if (_.isArray(a)) {
        return b;
      } else {
        return void 0;
      }
    };

    Automagic.prototype.page_body = function() {
      return _.find('body')[0];
    };

    Automagic.prototype.page_ready = function() {
      _.attr(this.page_body(), 'data-trakio-automagic', '1');
      this.identify.page_ready();
      if (this.options.bind_events) {
        return this.bind_events();
      }
    };

    Automagic.prototype.bind_events = function() {
      var body, form, _i, _len, _ref, _results;
      try {
        body = document.body || document.getElementsByTagName('body')[0];
        _ref = _.find(this.options.form_selector);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          form = _ref[_i];
          _results.push(this.bind_to_form_submit(form));
        }
        return _results;
      } catch (_error) {

      }
    };

    Automagic.prototype.bind_to_form_submit = function(form) {
      var me;
      me = this;
      return _.addEvent(form, 'submit', this.form_submitted);
    };

    Automagic.prototype.form_submitted = function(event, callback) {
      try {
        event.preventDefault();
        this.identify.form_submitted(event, callback);
        return false;
      } catch (_error) {
        return callback();
      }
    };

    return Automagic;

  })();
  Trak.Automagic = Automagic;
  Trak.Automagic.Identify = Identify;
  _ref = Trak.instances;
  _results = [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    instance = _ref[_i];
    _results.push(instance.loaded_automagic());
  }
  return _results;
});
