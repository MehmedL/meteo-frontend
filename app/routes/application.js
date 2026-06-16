import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class ApplicationRoute extends Route {
  @service session;

  // Зарежда и валидира сесията от сървъра преди guard-овете на под-route-овете.
  async beforeModel() {
    await this.session.load();
  }
}
