import Service from '@ember/service';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

export default class SessionService extends Service {
  @service api;

  @tracked currentUser = null;

  get isAuthenticated() {
    return Boolean(this.currentUser);
  }

  // Източник на истината е сървърът: проверяваме активната сесия през /me.
  async load() {
    try {
      this.currentUser = await this.api.get('/api/auth/me.php');
    } catch {
      this.currentUser = null;
    }
  }

  // Извиква се след успешен POST към login.php (сесията вече е създадена на сървъра).
  login(user) {
    this.currentUser = user;
  }

  async logout() {
    try {
      await this.api.post('/api/auth/logout.php', {});
    } finally {
      this.currentUser = null;
    }
  }
}
