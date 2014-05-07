({
  name: '../bower_components/almond/almond',
  baseUrl: '../src',
  out: '../trak.io.automagic.js',
  optimize: 'none',
  include: 'trakio/automagic',
  shim: {
    json2: {
      exports: 'JSON'
    }
  },
  paths: {
    lodash: '../vendor/lodash',
    json2:  '../bower_components/json2/json2',
    sizzle: '../bower_components/sizzle/dist/sizzle'
  },
  wrap: {
    start: "(function() {",
    end: "return require('trakio/automagic'); }());"
  }
})
