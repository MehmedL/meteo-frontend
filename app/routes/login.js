import UnauthenticatedRoute from 'meteo-frontend/routes/-base/unauthenticated';

export default class LoginRoute extends UnauthenticatedRoute {
  setupController(controller) {
    super.setupController(...arguments);
    controller.reset();
  }
}
