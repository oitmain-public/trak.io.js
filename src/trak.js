// Generated by IcedCoffeeScript 1.4.0c

define(['jsonp', 'exceptions', 'io-query', 'cookie', 'lodash'], function(JSONP, Exceptions, ioQuery, cookie, _) {
  var Trak;
  return Trak = (function() {

    Trak.prototype.loaded = true;

    Trak.prototype.Exceptions = Exceptions;

    Trak.prototype.cookie = cookie;

    function Trak() {
      this.io = this;
    }

    Trak.prototype.initialize = function(_api_token, options) {
      var me;
      this._api_token = _api_token;
      if (options == null) options = {};
      this.protocol(options.protocol);
      if (options.host) this.host(options.host);
      if (options.context) this.context(options.context);
      if (options.channel) this.channel(options.channel);
      this.distinct_id(options.distinct_id || null);
      this.root_domain(options.root_domain || null);
      if (options.auto_track_page_views !== false) {
        me = this;
        this.page_ready(function() {
          return me.page_view();
        });
      }
      return this;
    };

    Trak.prototype.initialise = function() {
      return this.initialize.apply(this, arguments);
    };

    Trak.prototype.page_ready_event_fired = false;

    Trak.prototype.page_ready = function(fn) {
      var do_scroll_check, idempotent_fn, me, toplevel;
      me = this;
      idempotent_fn = function() {
        if (me.page_ready_event_fired) return;
        me.page_ready_event_fired = true;
        return fn();
      };
      do_scroll_check = function() {
        if (this.page_ready_event_fired) return;
        try {
          document.documentElement.doScroll("left");
        } catch (e) {
          setTimeout(do_scroll_check, 1);
          return;
        }
        return idempotent_fn();
      };
      if (document.readyState === "complete") return idempotent_fn();
      if (document.addEventListener) {
        document.addEventListener("DOMContentLoaded", idempotent_fn, false);
        return window.addEventListener("load", idempotent_fn, false);
      } else if (document.attachEvent) {
        document.attachEvent("onreadystatechange", idempotent_fn);
        window.attachEvent("onload", idempotent_fn);
        toplevel = false;
        try {
          toplevel = window.frameElement == null;
        } catch (_error) {}
        if (document.documentElement.doScroll && toplevel) {
          return do_scroll_check();
        }
      }
    };

    Trak.prototype.jsonp = new JSONP();

    Trak.prototype.call = function() {
      return this.jsonp.call.apply(this.jsonp, arguments);
    };

    Trak.prototype.identify = function() {
      var args, callback, distinct_id, properties;
      args = this.sort_arguments(arguments, ['string', 'object', 'function']);
      distinct_id = args[0] || this.distinct_id();
      properties = args[1] || {};
      callback = args[2] || null;
      if (args[0]) this.alias(distinct_id);
      this.call('identify', {
        distinct_id: distinct_id,
        data: {
          properties: properties
        }
      }, callback);
      return this;
    };

    Trak.prototype.alias = function() {
      var alias, args, callback, distinct_id, update_distinct;
      args = this.sort_arguments(arguments, ['string', 'string', 'boolean', 'function']);
      distinct_id = (args[1] ? args[0] : void 0) || this.distinct_id();
      alias = args[1] ? args[1] : args[0];
      update_distinct = args[2] !== null ? args[2] : (args[1] ? false : true);
      callback = args[3] || null;
      if (!alias) {
        throw new Exceptions.MissingParameter('Missing a required parameter.', 400, 'You must provide an alias, see http://docs.trak.io/alias.html');
      }
      if (alias === distinct_id) {
        if (callback) {
          callback({
            status: 'unnecessary'
          });
        }
      } else {
        this.call('alias', {
          data: {
            distinct_id: distinct_id,
            alias: alias
          }
        }, callback);
        if (update_distinct) this.distinct_id(alias);
      }
      return this;
    };

    Trak.prototype.track = function() {
      var args, callback, channel, context, distinct_id, event, properties;
      args = this.sort_arguments(arguments, ['string', 'string', 'string', 'object', 'object', 'function']);
      distinct_id = (args[2] ? arguments[0] : void 0) || this.distinct_id();
      event = (args[2] ? args[1] : args[0]);
      channel = (args[2] ? args[2] : args[1]) || this.channel();
      properties = args[3] || {};
      context = args[4] || {};
      context = _.merge(this.context(), context);
      callback = args[5] || null;
      if (!event) {
        throw new Exceptions.MissingParameter('Missing a required parameter.', 400, 'You must provide an event to track, see http://docs.trak.io/track.html');
      }
      this.call('track', {
        data: {
          distinct_id: distinct_id,
          event: event,
          channel: channel,
          context: context,
          properties: properties
        }
      }, callback);
      return this;
    };

    Trak.prototype.page_view = function() {
      var args, callback, title, url;
      args = this.sort_arguments(arguments, ['string', 'string', 'function']);
      url = args[0] || this.url();
      title = args[1] || this.page_title();
      callback = args[2] || null;
      this.track('page_view', {
        url: url,
        page_title: title
      }, callback);
      return this;
    };

    Trak.prototype._protocol = 'https';

    Trak.prototype.protocol = function(value) {
      if (value) this._protocol = value;
      return "" + this._protocol + "://";
    };

    Trak.prototype._host = 'api.trak.io/v1';

    Trak.prototype.host = function(value) {
      if (value) this._host = value;
      return this._host;
    };

    Trak.prototype._current_context = false;

    Trak.prototype.current_context = function(key, value) {
      var c;
      if (!this._current_context) {
        if (c = this.get_cookie('context')) {
          this._current_context = JSON.parse(c);
        } else {
          this._current_context = {};
        }
      }
      if (typeof key === 'object') {
        _.merge(this._current_context, key);
      } else if (key && value) {
        this._current_context[key] = value;
      }
      this.set_cookie('context', JSON.stringify(this._current_context));
      return this._current_context;
    };

    Trak.prototype.default_context = function() {
      var referer, url;
      url = this.url();
      referer = this.referer();
      return {
        ip: null,
        user_agent: navigator.userAgent,
        page_title: this.page_title(),
        url: url,
        params: url.indexOf("?") > 0 ? ioQuery.queryToObject(url.substring(url.indexOf("?") + 1, url.length)) : {},
        referer: referer,
        referer_params: referer.indexOf("?") > 0 ? ioQuery.queryToObject(referer.substring(referer.indexOf("?") + 1, referer.length)) : {}
      };
    };

    Trak.prototype.context = function(key, value) {
      var r;
      r = {};
      _.merge(r, this.default_context(), this.current_context(key, value));
      return r;
    };

    Trak.prototype.url = function() {
      return window.location.href;
    };

    Trak.prototype.referer = function() {
      return document.referrer;
    };

    Trak.prototype.page_title = function() {
      return document.title;
    };

    Trak.prototype.hostname = function() {
      return document.location.hostname;
    };

    Trak.prototype.url_params = function() {
      return window.location.search;
    };

    Trak.prototype.get_distinct_id_url_param = function() {
      var matches;
      if ((matches = this.url_params().match(/\?.*trak_distinct_id\=([^&]+).*/))) {
        return decodeURIComponent(matches[1]);
      }
    };

    Trak.prototype._channel = false;

    Trak.prototype.channel = function(value) {
      if (!this._channel && !(this._channel = this.get_cookie('channel'))) {
        this._channel = this.hostname() || 'web_site';
      }
      if (value) {
        this._channel = value;
        this.set_cookie('channel', value);
      }
      return this._channel;
    };

    Trak.prototype._api_token = null;

    Trak.prototype.api_token = function() {
      return this._api_token;
    };

    Trak.prototype._distinct_id = null;

    Trak.prototype.distinct_id = function(value) {
      if (value) this._distinct_id = value;
      if (!this._distinct_id && !(this._distinct_id = this.get_distinct_id_url_param()) && !(this._distinct_id = this.get_cookie('id'))) {
        this._distinct_id = this.generate_distinct_id();
      }
      cookie.set(this.cookie_key('id'), this._distinct_id, {
        domain: this.root_domain()
      });
      return this._distinct_id;
    };

    Trak.prototype.generate_distinct_id = function() {
      return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r, v;
        r = Math.random() * 16 | 0;
        v = c === 'x' ? r : r & 0x3 | 0x8;
        return v.toString(16);
      });
    };

    Trak.prototype._root_domain = null;

    Trak.prototype.root_domain = function(value) {
      if (!value && !this._root_domain) this._root_domain = this.get_root_domain();
      if (value) this._root_domain = value;
      return this._root_domain;
    };

    Trak.prototype.get_root_domain = function() {
      var domain, parts;
      if (this.hostname().match(/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/i) || this.hostname() === 'localhost') {
        return this.hostname();
      } else {
        parts = this.hostname().split('.');
        domain = parts.pop();
        while (parts.length > 0) {
          if (this.can_set_cookie({
            domain: domain
          })) break;
          domain = "" + (parts.pop()) + "." + domain;
        }
        return domain;
      }
    };

    Trak.prototype.set_cookie = function(key, value) {
      return cookie.set(this.cookie_key(key), value);
    };

    Trak.prototype.get_cookie = function(key) {
      return cookie.get(this.cookie_key(key));
    };

    Trak.prototype.can_set_cookie = function(options) {
      cookie.set(this.cookie_key('foo'), '');
      cookie.set(this.cookie_key('foo'), '', options);
      cookie.set(this.cookie_key('foo'), 'bar', options);
      return cookie.get(this.cookie_key('foo')) === 'bar';
    };

    Trak.prototype.cookie_key = function(key) {
      return "_trak_" + (this.api_token()) + "_" + key;
    };

    Trak.prototype.sort_arguments = function(values, types) {
      var r, type, value, _i, _len;
      values = Array.prototype.slice.call(values);
      r = [];
      value = values.shift();
      for (_i = 0, _len = types.length; _i < _len; _i++) {
        type = types[_i];
        if (type === typeof value) {
          r.push(value);
          value = values.shift();
        } else {
          r.push(null);
        }
      }
      return r;
    };

    return Trak;

  })();
});
