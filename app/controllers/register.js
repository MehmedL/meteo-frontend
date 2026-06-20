import Controller from '@ember/controller';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

function todayISO() {
  return new Date().toISOString().slice(0, 10);
}

function plusOneYearISO() {
  const d = new Date();
  d.setFullYear(d.getFullYear() + 1);
  return d.toISOString().slice(0, 10);
}

export default class RegisterController extends Controller {
  @service api;
  @service router;

  @tracked user = '';
  @tracked password = '';
  @tracked mode = 'window';
  @tracked from = todayISO();
  @tracked to = plusOneYearISO();
  @tracked nmax = 10;
  @tracked error = null;
  @tracked success = false;
  @tracked isSubmitting = false;

  reset() {
    this.user = '';
    this.password = '';
    this.mode = 'window';
    this.from = todayISO();
    this.to = todayISO();
    this.nmax = 10;
    this.error = null;
    this.success = false;
    this.isSubmitting = false;
  }

  get isWindow() {
    return this.mode === 'window';
  }

  get isCount() {
    return this.mode === 'count';
  }

  get isDisabled() {
    return this.isSubmitting || !this.user.trim() || !this.password;
  }

  @action
  updateField(field, event) {
    this[field] = event.target.value;
    this.error = null;
  }

  @action
  setMode(event) {
    this.mode = event.target.value;
    this.error = null;
  }

  @action
  async submit(event) {
    event.preventDefault();

    if (this.isDisabled) {
      return;
    }

    const body = {
      user: this.user.trim(),
      password: this.password,
      mode: this.mode,
    };

    if (this.isWindow) {
      body.from = this.from;
      body.to = this.to;
    } else {
      body.nmax = Number(this.nmax);
    }

    this.isSubmitting = true;
    this.error = null;

    try {
      await this.api.post('/api/auth/register.php', body);
      this.success = true;
    } catch (e) {
      this.error = e.message || 'Възникна грешка при регистрацията.';
    } finally {
      this.isSubmitting = false;
    }
  }
}
