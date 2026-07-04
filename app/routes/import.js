import AdminRoute from 'meteo-frontend/routes/-base/admin';
import { service } from '@ember/service';
import { hash } from 'rsvp';

export default class ImportRoute extends AdminRoute {
  @service api;

  model() {
    return hash({
      devices: this.api.get('/api/devices/index.php'),
      phenomena: this.api.get('/api/phenomenon/index.php'),
      cameraModes: this.api.get('/api/cameramode/index.php'),
    });
  }

  setupController(controller, model) {
    super.setupController(...arguments);
    controller.devices = model.devices ?? [];
    controller.phenomena = model.phenomena ?? [];
    controller.cameraModes = model.cameraModes ?? [];
    controller.reset();
  }
}
