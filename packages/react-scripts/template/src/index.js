import React from 'react';
import ReactDOM from 'react-dom';
import { Router, Route, browserHistory } from 'react-router';
// import { createStore, applyMiddleware, compose } from 'redux';
// import { Provider } from 'react-redux';
// import thunk from 'redux-thunk';

import 'bootstrap/scss/bootstrap.scss';
import 'font-awesome/scss/font-awesome.scss';

import './index.scss';
import App from './App';
import * as serviceWorker from './serviceWorker';

// import reducers from './store/reducers';

// import { requireAuthentication, Login } from './login/authentication';

// const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;
// const store = createStore(reducers, composeEnhancers(applyMiddleware(thunk)));

/*
ReactDOM.render(
    <Provider store={store}>
      <Router history={browserHistory}>
        <Route path='/login' component={Login}/>
        <Route path='/' component={App} onEnter={requireAuthentication}/>
      </Router>
    </Provider>,
    document.getElementById('root')
);
*/

ReactDOM.render(
        <Router history={browserHistory}>
            <Route path='/' component={App}/>
        </Router>,
    document.getElementById('root')
);

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: http://bit.ly/CRA-PWA
serviceWorker.unregister();
