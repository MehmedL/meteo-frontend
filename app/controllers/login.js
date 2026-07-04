import Controller from '@ember/controller';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

function isValidEmail(value) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value.trim());
}

export default class LoginController extends Controller {
  @service api;
  @service session;
  @service router;

  @tracked email = '';
  @tracked password = '';
  @tracked error = null;
  @tracked isSubmitting = false;

  reset() {
    this.email = '';
    this.password = '';
    this.error = null;
    this.isSubmitting = false;
  }

  get isDisabled() {
    return (
      this.isSubmitting ||
      !isValidEmail(this.email) ||
      !this.password
    );
  }

  @action
  updateEmail(event) {
    this.email = event.target.value;
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
        email: this.email.trim().toLowerCase(),
        password: this.password,
      });

      this.session.login(data);
      this.email = '';
      this.password = '';
      await this.router.transitionTo('index');
    } catch (e) {
      this.error = e.message || 'Възникна грешка при входа.';
    } finally {
      this.isSubmitting = false;
    }
  }
}
