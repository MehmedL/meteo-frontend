import Service from '@ember/service';
import config from 'meteo-frontend/config/environment';

const API_HOST = config.APP.API_HOST;

class ApiError extends Error {
  constructor(message, { status, body } = {}) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.body = body;
  }
}

export default class ApiService extends Service {
  get host() {
    return API_HOST;
  }

  url(path) {
    return `${API_HOST}${path.startsWith('/') ? path : `/${path}`}`;
  }

  async #handle(response) {
    let payload;
    try {
      payload = await response.json();
    } catch {
      throw new ApiError(`Невалиден JSON отговор (HTTP ${response.status})`, {
        status: response.status,
      });
    }

    if (!response.ok || payload?.success === false) {
      const message =
        payload?.error || `Заявката се провали (HTTP ${response.status})`;
      throw new ApiError(message, { status: response.status, body: payload });
    }

    return payload?.data;
  }

  async get(path) {
    const response = await fetch(this.url(path), {
      headers: { Accept: 'application/json' },
      credentials: 'include',
    });
    return this.#handle(response);
  }

  async getBlob(path) {
    const response = await fetch(this.url(path), { credentials: 'include' });

    const contentType = response.headers.get('Content-Type') ?? '';
    if (!response.ok || contentType.includes('application/json')) {
      const payload = await response.json().catch(() => null);
      throw new ApiError(
        payload?.error || `Заявката се провали (HTTP ${response.status})`,
        { status: response.status, body: payload },
      );
    }

    return response.blob();
  }

  async post(path, body) {
    const response = await fetch(this.url(path), {
      method: 'POST',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
      },
      credentials: 'include',
      body: JSON.stringify(body),
    });
    return this.#handle(response);
  }

  async upload(path, file, fieldName = 'file') {
    const formData = new FormData();
    formData.append(fieldName, file);

    return this.submitForm(path, formData);
  }

  async submitForm(path, formData) {
    const response = await fetch(this.url(path), {
      method: 'POST',
      headers: { Accept: 'application/json' },
      credentials: 'include',
      body: formData,
    });
    return this.#handle(response);
  }
}
