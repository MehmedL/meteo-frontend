import Controller from '@ember/controller';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

export default class LoginController extends Controller {
  @service api;
  @service session;
  @service router;

  @tracked user = '';
  @tracked password = '';
  @tracked error = null;
  @tracked isSubmitting = false;

  reset() {
    this.user = '';
    this.password = '';
    this.error = null;
    this.isSubmitting = false;
  }

  get isDisabled() {
    return this.isSubmitting || !this.user.trim() || !this.password;
  }

  @action
  updateUser(event) {
    this.user = event.target.value;
    this.error = null;
  }

  @action
  updatePassword(event) {
    this.password = event.target.value;
    this.error = null;
  }

  @action
  async submit(event) {
    event.preventDefault();

    if (this.isDisabled) {
      return;
    }

    this.isSubmitting = true;
    this.error = null;

    try {
      const data = await this.api.post('/api/auth/login.php', {
        user: this.user.trim(),
        password: this.password,
      });

      this.session.login(data);
      this.user = '';
      this.password = '';
      await this.router.transitionTo('index');
    } catch (e) {
      this.error = e.message || 'Възникна грешка при входа.';
    } finally {
      this.isSubmitting = false;
    }
  }
}
