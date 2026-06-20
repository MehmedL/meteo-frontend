import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class RegisterRoute extends Route {
  @service session;
  @service router;

  beforeModel() {
    if (this.session.isAuthenticated) {
      this.router.transitionTo('index');
    }
  }

  setupController(controller) {
    super.setupController(...arguments);
    controller.reset();
  }
}
