
var Service = require('node-windows').Service;
var ini = require('ini');

var fs = require('fs');
var child_process = require('child_process');

process.on('uncaughtException',function(err) {
  console.error(err);
});

try {
  var config = ini.decode(fs.readFileSync('./serviceConfig.ini').toString()).service;
} catch(e) {
  console.error('cannot parse serviceConfig.ini: ',e);
  process.exit();
}

// Create a new service object
var svc = new Service(config);

// console.log(JSON.stringify(config));

switch (process.argv[2]) {

  case 'install':
    svc.on('alreadyinstalled',function(){
      // this only checks for service executable, not service listing:-(
      console.log('Service already installed');
      svc.restart();
    });

    svc.on('install',function(){
      svc.start();
    });

    svc.install();
    break;

  case 'uninstall':
    svc.on('uninstall',function(){
      console.log('Uninstall complete');
      console.log('The service exists: ',svc.exists);
    });

    svc.uninstall();
    break;

  case 'restart':
    svc.on('start',function(){
      console.log('Service restarted');
      console.log('The service exists: ',svc.exists);
    });

    svc.restart();
    break;

  case 'start':
    svc.on('start',function(){
      console.log('Service started');
      console.log('The service exists: ',svc.exists);
    });

    svc.start();
    break;

  case 'stop':
    svc.on('stop',function(){
      console.log('Service stopped');
      console.log('The service exists: ',svc.exists);
    });

    svc.stop();
    break;

  case 'status':
    child_process.exec('sc interrogate '+svc.id+'.exe', function(err,stdout,stderr) {
      console.log(err);
      console.log(stdout);
      console.log(stderr);
    });
    break;

  case 'exists':
    console.log('The service exists: ',svc.exists);
    break;

}
