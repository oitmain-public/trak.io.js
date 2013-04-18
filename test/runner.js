// `ignoreLeaks` because analytics services are supposed to leak things.
chai.should();
expect = chai.expect;

requirejs(['trak.io'], function() {

  $(document).ready(function() {
    // Log errors in IE for easier testing.
    if (window.onerror) {
      window.onerror = console.log
    }

    if (window.mochaPhantomJS) {
      window.mochaPhantomJS.run()
    } else {
      window.mocha.run()
    }
  });
});

