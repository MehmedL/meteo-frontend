import Route from '@ember/routing/route';
import { service } from '@ember/service';

// Базов клас за публичните рутери (login/register).
// Ако вече логнат потребител изпише пълния път в URL-а,
// го пренасочваме обратно към началната страница.
export default class UnauthenticatedRoute extends Route {
  @service session;
  @service router;

  beforeModel(transition) {
    super.beforeModel(...arguments);

    if (this.session.canAccessApp) {
      this.router.transitionTo('index');
    }

    return transition;
  }
}
