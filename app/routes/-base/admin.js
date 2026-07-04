import Route from '@ember/routing/route';
import { service } from '@ember/service';

// Базов клас за рутери, изискващи логнат администратор.
// Проверява директно session.canAccessApp/isAdmin, за да не се стрелят
// два конкуриращи се redirect-а (към login и към index) в един и същ тик.
export default class AdminRoute extends Route {
  @service session;
  @service router;

  beforeModel(transition) {
    super.beforeModel(...arguments);

    if (!this.session.canAccessApp) {
      transition.abort();
      return this.router.transitionTo('login');
    }

    if (!this.session.isAdmin) {
      transition.abort();
      return this.router.transitionTo('index');
    }
  }
}
