import EmberRouter from '@embroider/router';
import config from 'meteo-frontend/config/environment';

export default class Router extends EmberRouter {
  location = config.locationType;
  rootURL = config.rootURL;
}

Router.map(function () {
  this.route('import');
  this.route('search');
  this.route('login');
  this.route('register');
  this.route('not-found', { path: '/*path' });
});
