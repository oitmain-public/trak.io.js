// Generated by IcedCoffeeScript 1.7.1-b
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['exception'], function(Exception) {
  var Timeout;
  return Timeout = (function(_super) {
    __extends(Timeout, _super);

    function Timeout() {
      return Timeout.__super__.constructor.apply(this, arguments);
    }

    return Timeout;

  })(Exception);
});
