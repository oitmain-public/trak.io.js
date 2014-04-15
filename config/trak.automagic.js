({
  name: '../bower_components/almond/almond',
  baseUrl: '../src',
  out: '../trak.automagic.js',
  optimize: 'none',
  include: 'trak.automagic',
  insertRequire: ['trak.automagic'],
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
