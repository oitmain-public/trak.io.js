/*
 * Simple connect server for phantom.js
 * Adapted from twitter bootstrap server.
 */

var connect = require('connect')
  , http    = require('http')
  , fs      = require('fs')
  , path    = require('path')
  , app     = connect()
  , argv    = require('optimist')
                .default('port', 8001)
                .argv;

var port = (argv.p || argv.port);

var pidFile = path.resolve(__dirname, './pid.'+port+'.txt');

app.use(connect.static(path.resolve(__dirname, '.')));

http.createServer(app).listen(port, function () {
  fs.writeFileSync(pidFile, process.pid, 'utf-8');
});

