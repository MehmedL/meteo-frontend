import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class NotFoundRoute extends Route {
  @service session;
  @service router;

  beforeModel() {
    super.beforeModel(...arguments);

    if (this.session.canAccessApp) {
      this.router.transitionTo('index');
    } else {
      this.router.transitionTo('login');
    }
  }
}
