import AuthenticatedRoute from 'meteo-frontend/routes/-base/authenticated';
import { service } from '@ember/service';

export default class DashboardRoute extends AuthenticatedRoute {
  @service api;

  async model() {
    return this.api.get('/api/stats/index.php');
  }
}
