import Route from '@ember/routing/route';
import { service } from '@ember/service';

// Базов клас за всички рутери, които изискват логнат потребител с активен достъп.
// Дори при директно изписване на пълния път в URL-а, неаутентикиран
// или с изтекъл достъп потребител се пренасочва към login.
export default class AuthenticatedRoute extends Route {
  @service session;
  @service router;

  beforeModel(transition) {
    super.beforeModel(...arguments);

    if (!this.session.canAccessApp) {
      transition.abort();
      return this.router.transitionTo('login');
    }
  }
}
