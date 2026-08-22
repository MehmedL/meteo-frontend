import Controller from '@ember/controller';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

function todayISO() {
  return new Date().toISOString().slice(0, 10);
}

function tomorrowISO() {
  const d = new Date();
  d.setDate(d.getDate() + 1);
  return d.toISOString().slice(0, 10);
}

function addMaxWindowISO(dateStr) {
  const d = new Date(dateStr);
  d.setDate(d.getDate() + 10);
  return d.toISOString().slice(0, 10);
}

function isValidEmail(value) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value.trim());
}

export default class RegisterController extends Controller {
  @service api;
  @service router;

  @tracked email = '';
  @tracked password = '';
  @tracked mode = 'window';
  @tracked from = todayISO();
  @tracked to = tomorrowISO();
  @tracked nmax = 10;
  @tracked error = null;
  @tracked success = false;
  @tracked isSubmitting = false;

  reset() {
    this.email = '';
    this.password = '';
    this.mode = 'window';
    this.from = todayISO();
    this.to = tomorrowISO();
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

  get toMin() {
    return this.from;
  }

  get toMax() {
    return addMaxWindowISO(this.from);
  }

  get isDisabled() {
    if (this.isSubmitting || !isValidEmail(this.email) || !this.password) {
      return true;
    }

    if (this.isCount) {
      const n = Number(this.nmax);
      if (!Number.isInteger(n) || n < 1 || n > 10) {
        return true;
      }
    }

    if (this.isWindow) {
      if (!this.from || !this.to || this.to < this.from || this.to > this.toMax) {
        return true;
      }
    }

    return false;
  }

  @action
  updateField(field, event) {
    this[field] = event.target.value;

    if (field === 'from' && this.to > this.toMax) {
      this.to = this.toMax;
    }

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
      email: this.email.trim().toLowerCase(),
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
      this.password = '';
    } catch (e) {
      this.error = e.message || 'Възникна грешка при регистрацията.';
    } finally {
      this.isSubmitting = false;
    }
  }
}
