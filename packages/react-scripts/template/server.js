var express = require('express');
var ini = require('ini');

var fs = require('fs');

process.chdir(__dirname); // really
console.log('working directory: '+__dirname);

process.on('uncaughtException',function(err){
  console.error(''+err);
});

try {
  var config = ini.decode(fs.readFileSync('./serviceConfig.ini').toString());
  console.log(JSON.stringify(config,null,' '));
} catch(e) {
  console.error('cannot parse serviceConfig.ini: ',e);
  process.exit();
}

var directory = __dirname + '/' + (process.argv[2] || './build');

var app = express();

app.use('*', function (req, resp, next) {
  console.log(req.hostname, req.method, req.originalUrl);
  next();
});

app.use(express.static(directory));

app.use('*',function (req, resp) {
  resp.sendFile(directory + '/index.html');
});

// Listen
app.listen(config.service.port, config.service.hostname, function () {
  console.log('listening on ',config.service.port, config.service.hostname);
});
