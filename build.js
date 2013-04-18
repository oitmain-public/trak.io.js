({
  name: 'trak.io', // I guess it needs a name too
  baseUrl: 'src', // Base url for importing/requiring scripts (* relative to appDir)
  out: 'trak.io.js',
  optimize: 'none',
  include: 'requireLib',
  shim: {
    lodash: {
      exports: '_'
    },
    json2: {
      exports: 'JSON'
    }
  },
  paths: {
    requireLib: '../components/requirejs/require',
    lodash: '../components/lodash/dist/lodash.compat.min',
    json2: '../components/json2/json2',
    cookie: '../components/cookie/cookie',
    dojo: '../components/dojo'
  }
})