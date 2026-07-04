import Route from '@ember/routing/route';
import { service } from '@ember/service';

// Catch-all рутер за всеки непознат път (/*path).
// Пренасочва според състоянието на сесията:
//   логнат → начало (index), нелогнат → login.
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
