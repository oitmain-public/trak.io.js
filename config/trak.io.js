({
  name: '../bower_components/almond/almond',
  baseUrl: '../src',
  out: '../trak.io.js',
  optimize: 'none',
  include: 'trak.io',
  insertRequire: ['trak.io'],
  shim: {
    json2: {
      exports: 'JSON'
    }
  },
  paths: {
    lodash: '../vendor/lodash',
    json2: '../bower_components/json2/json2',
    cookie: '../bower_components/cookie.js/cookie'
  },
  wrap: {
    start: "(function() {",
    end: "}());"
  }
})
