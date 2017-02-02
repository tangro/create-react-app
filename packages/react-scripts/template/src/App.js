import React, { Component } from 'react';
import Helmet from 'react-helmet';

import './App.scss';
import PACKAGE from '../package.json';

class App extends Component {
  render() {
    return (
      <div className="App">
        <Helmet title={PACKAGE.name + ' - ' + PACKAGE.version}/>
        <div className="App-header">
          <h2>Welcome to React</h2>
        </div>
        <p className="App-intro">
          To get started, edit <code>src/App.js</code> and save to reload.
        </p>
      </div>
    );
  }
}

export default App;
