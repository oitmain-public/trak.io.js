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
    json2: '../bower_components/json2/json2'
  },
  wrap: {
    start: "(function() {",
    end: "}());"
  }
})
