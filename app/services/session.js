import Service from '@ember/service';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

export default class SessionService extends Service {
  @service api;

  @tracked currentUser = null;

  get isAuthenticated() {
    return Boolean(this.currentUser);
  }

  get isAdmin() {
    return this.currentUser?.role === 'admin';
  }

  get hasActiveAccess() {
    if (!this.currentUser) {
      return false;
    }

    if (this.isAdmin) {
      return true;
    }

    return this.currentUser.accessActive !== false;
  }

  get canAccessApp() {
    return this.isAuthenticated && this.hasActiveAccess;
  }

  async load() {
    try {
      this.currentUser = await this.api.get('/api/auth/me.php');
    } catch {
      this.currentUser = null;
    }
  }

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
