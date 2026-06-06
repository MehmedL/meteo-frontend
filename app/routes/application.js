import Route from '@ember/routing/route';
import config from 'meteo-frontend/config/environment';

export default class ApplicationRoute extends Route {
  async model() {
    const url = `${config.APP.API_HOST}/api/hello.php`;

    try {
      const response = await fetch(url);

      if (!response.ok) {
        return { ok: false, error: `HTTP ${response.status}`, url };
      }

      const data = await response.json();
      return { ok: true, message: data.message, url };
    } catch (e) {
      return { ok: false, error: e.message, url };
    }
  }
}
