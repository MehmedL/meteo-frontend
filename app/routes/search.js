import AuthenticatedRoute from 'meteo-frontend/routes/-base/authenticated';
import { service } from '@ember/service';

export default class SearchRoute extends AuthenticatedRoute {
  @service api;

  async model() {
    const [phenomena, devices] = await Promise.all([
      this.api.get('/api/phenomenon/index.php'),
      this.api.get('/api/devices/index.php'),
    ]);
    return { phenomena, devices };
  }

  setupController(controller, model) {
    super.setupController(...arguments);
    controller.phenomena = model.phenomena ?? [];
    controller.devices = model.devices ?? [];
  }
}
