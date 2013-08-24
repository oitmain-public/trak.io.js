({
  name: '../components/almond/almond',
  baseUrl: 'src',
  out: 'trak.io.js',
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
    json2: '../components/json2/json2',
    cookie: '../components/cookie/cookie'
  },
  wrap: {
    start: "(function() {",
    end: "}());"
  }
})