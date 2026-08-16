import AdminRoute from 'meteo-frontend/routes/-base/admin';
import { service } from '@ember/service';

export default class ImportRoute extends AdminRoute {
  @service api;

  async model() {
    const [devices, phenomena, cameraModes] = await Promise.all([
      this.api.get('/api/devices/index.php'),
      this.api.get('/api/phenomenon/index.php'),
      this.api.get('/api/cameramode/index.php'),
    ]);
    return { devices, phenomena, cameraModes };
  }

  setupController(controller, model) {
    super.setupController(...arguments);
    controller.devices = model.devices ?? [];
    controller.phenomena = model.phenomena ?? [];
    controller.cameraModes = model.cameraModes ?? [];
    controller.reset();
  }
}
