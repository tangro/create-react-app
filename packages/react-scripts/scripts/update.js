/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

var fs = require('fs-extra');
var path = require('path');
var paths = require('../config/paths');
var spawn = require('cross-spawn');
var chalk = require('chalk');
var dod = require('deep-object-diff');
var JsDiff = require('diff');

// module.exports = function(appPath, appName, options) {
  var appPath = paths.appPath;
  var appName = path.basename(appPath);

  var ownPackageJson = require(path.join(__dirname, '..', 'package.json'));
  var ownPackageName = ownPackageJson.name;
  var exportedDependencies = ownPackageJson.exportedDependencies;
  var ownPath = path.join(appPath, 'node_modules', ownPackageName);
  var appPackage = {};

  // Copy over some of the devDependencies
  appPackage.dependencies = Object.assign({}, appPackage.dependencies, exportedDependencies.dependencies);
  appPackage.devDependencies = Object.assign({}, appPackage.devDependencies, exportedDependencies.devDependencies);
  appPackage.optDependencies = Object.assign({}, appPackage.optDependencies, exportedDependencies.optDependencies);

  // Setup the script rules
  appPackage.scripts = {
    'start': 'react-scripts start',
    'build': 'react-scripts build',
    'test': 'react-scripts test --env=jsdom',
    'eject': 'react-scripts eject',
    'update': 'react-scripts update',
    'buildinstaller': 'helper buildinstaller'
  };

  var currentPackage = require(path.join(appPath, 'package.json'));
  var reference = {
      dependencies: currentPackage.dependencies,
      devDependencies: currentPackage.devDependencies,
      optDependencies: currentPackage.optDependencies,
      scripts: currentPackage.scripts
  };

  console.log('==== package.json');
  console.log('== added entries');
  var addedDependencies = dod.addedDiff(reference, appPackage);
  console.log(addedDependencies);
  console.log('== updated entries');
  var updatedDependencies = dod.updatedDiff(reference, appPackage);
  console.log(updatedDependencies);

  if (process.argv.indexOf('--package.json')!==-1) {
    var updatedPackage = Object.keys(addedDependencies).reduce(function (package, key) {
                              return Object.assign(package, {[key]: Object.assign(package[key], addedDependencies[key]) })
                          }, currentPackage);
    updatedPackage = Object.keys(updatedDependencies).reduce(function (package, key) {
        return Object.assign(package, {[key]: Object.assign(package[key], updatedDependencies[key]) })
    }, currentPackage);

    console.log('== writing updated package.json')
    console.log(JSON.stringify(updatedPackage,null,2));
    fs.writeFileSync(path.join(appPath, 'package.json'), JSON.stringify(updatedPackage,null,2));
  }

  function adjust(file) {
      switch (file) {
          case 'gitignore':     return '.gitignore';
          case 'react-app.nsi': return appName + '.nsi';
          default:              return file;
      }
  }
  function dirTree(templateDir, projectDir) {
      fs.readdir(templateDir, function (err, files) {
          files.forEach(function (file) {
            var templatePath = templateDir + path.sep + file;
            var projectPath = projectDir + path.sep + adjust(file);
            if (!fs.existsSync(projectPath)) {
              console.log('new file/dir:', templatePath, file!=adjust(file) && `(should become ${projectPath})`);
            } else {
              fs.stat(templatePath, function (err, stats) {
                  if (stats.isDirectory()) {
                    dirTree(templatePath, projectPath);
                  } else if (stats.isFile()) {
                    var diff = JsDiff.createTwoFilesPatch(projectPath, templatePath, fs.readFileSync(projectPath,'utf8'), fs.readFileSync(templatePath,'utf8'));
                    var lines = diff.split(/\r\n|\r|\n/).length;
                    if (lines>4) {
                      console.log(`changed file: ${templatePath} differs from ${projectPath}`);
                      process.argv.indexOf('--diff')!==-1 && console.log(diff);
                    } else {
                      console.log(`unchanged file: ${projectPath}`);
                    }
                  }
              });
            }
          })
      })
  }

  // compare with template
  var templatePath = path.join(ownPath, 'template');
  if (fs.existsSync(templatePath)) {
    console.log('==== template')
    dirTree(templatePath,appPath);
  } else {
    console.error('Could not locate supplied template: ' + chalk.green(templatePath));
    return;
  }

  /*
  // rename according to appName
  fs.move(path.join(appPath, 'react-app.nsi'), path.join(appPath, appName + '.nsi'), function(err) {
    if (err) {
      console.error(err);
    }
  });
  fs.writeFileSync(path.join(appPath, 'serviceConfig.ini'), fs.readFileSync(path.join(appPath, 'serviceConfig.ini'),'utf8')
      .split('\n')
      .map( function(line) { return line.replace('react-app', appName); })
      .join('\n')
  );
  */

// };
