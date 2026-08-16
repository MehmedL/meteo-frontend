import Controller from '@ember/controller';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

export const DIRECTIONS = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
export const PATCH_COUNT = 9;

// DOM id-та на съответните полета в import.gjs — ползват се, за да можем
// да скролнем/фокусираме първото липсващо задължително поле при submit.
const REQUIRED_FIELD_IDS = {
  videoFile: 'import-field-video',
  imageFile: 'import-field-image',
  zipFile: 'import-field-zip',
  device: 'import-field-device',
  xGPS: 'import-field-xgps',
  yGPS: 'import-field-ygps',
  dir: 'import-field-dir',
  sdata: 'import-field-sdata',
  patches: 'import-patches-heading',
};

function toBackendDateTime(value) {
  if (!value) {
    return null;
  }
  const [datePart, timePart] = value.split('T');
  if (!datePart || !timePart) {
    return null;
  }
  const seconds = timePart.length === 5 ? `${timePart}:00` : timePart;
  return `${datePart} ${seconds}`;
}

export class Patch {
  index;
  @tracked phenomena = [];
  @tracked txtFile = null;
  @tracked collapsed = false;

  constructor(index) {
    this.index = index;
  }

  get txtName() {
    return this.txtFile?.name ?? '';
  }

  get isEmpty() {
    return this.phenomena.length === 0 && !this.txtFile;
  }

  get summary() {
    if (this.isEmpty) {
      return 'Няма данни';
    }

    const parts = [];
    if (this.phenomena.length > 0) {
      parts.push(`${this.phenomena.length} явл.`);
    }
    if (this.txtFile) {
      parts.push(this.txtFile.name);
    }
    return parts.join(' · ');
  }

  hasPhenomenon(id) {
    return this.phenomena.includes(id);
  }
}

export default class ImportController extends Controller {
  @service api;

  directions = DIRECTIONS;

  // Съвпадат с лимитите за размер на файла в backend config/uploads.php —
  // проверяваме клиентски, за да не чакаме пълен upload на твърде голям файл.
  maxVideoSize = 1024 * 1024 * 1024;
  maxImageSize = 25 * 1024 * 1024;
  maxZipSize = 512 * 1024 * 1024;

  @tracked devices = [];
  @tracked phenomena = [];
  @tracked cameraModes = [];

  @tracked videoFile = null;
  @tracked imageFile = null;
  @tracked zipFile = null;

  @tracked device = '';
  @tracked newDeviceName = '';
  @tracked showNewDevice = false;
  @tracked addingDevice = false;

  @tracked newPhenomenonName = '';
  @tracked showNewPhenomenon = false;
  @tracked addingPhenomenon = false;

  @tracked xGPS = '';
  @tracked yGPS = '';
  @tracked dir = '';
  @tracked sdata = '';
  @tracked cammod = '';

  @tracked patches = [];

  @tracked isSubmitting = false;
  @tracked error = null;
  @tracked success = null;
  @tracked submitAttempted = false;

  reset() {
    this.videoFile = null;
    this.imageFile = null;
    this.zipFile = null;
    this.device = '';
    this.newDeviceName = '';
    this.showNewDevice = false;
    this.addingDevice = false;
    this.newPhenomenonName = '';
    this.showNewPhenomenon = false;
    this.addingPhenomenon = false;
    this.xGPS = '';
    this.yGPS = '';
    this.dir = '';
    this.sdata = '';
    this.cammod = '';
    this.patches = [new Patch(0)];
    this.isSubmitting = false;
    this.error = null;
    this.success = null;
    this.submitAttempted = false;
  }

  @action
  updateField(field, event) {
    this[field] = event.target.value;
    this.error = null;
  }

  @action
  setVideo(file) {
    this.videoFile = file;
    this.error = null;
  }

  @action
  setImage(file) {
    this.imageFile = file;
    this.error = null;
  }

  @action
  setZip(file) {
    this.zipFile = file;
    this.error = null;
  }

  get panelOpen() {
    return this.showNewDevice || this.showNewPhenomenon;
  }

  @action
  toggleNewDevice() {
    this.showNewDevice = !this.showNewDevice;
    if (this.showNewDevice) {
      this.showNewPhenomenon = false;
      this.newPhenomenonName = '';
    } else {
      this.newDeviceName = '';
    }
    this.error = null;
  }

  @action
  async addDevice() {
    const name = this.newDeviceName.trim();
    if (!name || this.addingDevice) {
      return;
    }

    this.addingDevice = true;
    this.error = null;

    try {
      const created = await this.api.post('/api/devices/create.php', {
        device: name,
      });

      const exists = this.devices.some((d) => d.id === created.id);
      if (!exists) {
        this.devices = [...this.devices, created];
      }

      this.device = String(created.id);
      this.newDeviceName = '';
      this.showNewDevice = false;
    } catch (e) {
      this.error = e.message || 'Устройството не може да бъде добавено.';
    } finally {
      this.addingDevice = false;
    }
  }

  @action
  toggleNewPhenomenon() {
    this.showNewPhenomenon = !this.showNewPhenomenon;
    if (this.showNewPhenomenon) {
      this.showNewDevice = false;
      this.newDeviceName = '';
    } else {
      this.newPhenomenonName = '';
    }
    this.error = null;
  }

  @action
  async addPhenomenon() {
    const name = this.newPhenomenonName.trim();
    if (!name || this.addingPhenomenon) {
      return;
    }

    this.addingPhenomenon = true;
    this.error = null;

    try {
      const created = await this.api.post('/api/phenomenon/create.php', {
        phenom: name,
      });

      const exists = this.phenomena.some((p) => p.id === created.id);
      if (!exists) {
        this.phenomena = [...this.phenomena, created];
      }

      this.newPhenomenonName = '';
      this.showNewPhenomenon = false;
    } catch (e) {
      this.error = e.message || 'Явлението не може да бъде добавено.';
    } finally {
      this.addingPhenomenon = false;
    }
  }

  @action
  togglePhenomenon(patch, phenomId) {
    if (patch.phenomena.includes(phenomId)) {
      patch.phenomena = patch.phenomena.filter((id) => id !== phenomId);
    } else {
      patch.phenomena = [...patch.phenomena, phenomId];
    }
    this.error = null;
  }

  @action
  setPatchTxt(patch, file) {
    patch.txtFile = file;
    this.error = null;
  }

  get canAddPatch() {
    return this.patches.length < PATCH_COUNT;
  }

  @action
  addPatch() {
    if (!this.canAddPatch) {
      return;
    }
    for (const patch of this.patches) {
      patch.collapsed = true;
    }
    this.patches = [...this.patches, new Patch(this.patches.length)];
    this.error = null;
  }

  @action
  togglePatchCollapse(patch) {
    patch.collapsed = !patch.collapsed;
  }

  // Ключове на задължителните полета, които все още не са попълнени,
  // в реда, в който се показват във формата.
  get missingRequiredKeys() {
    const missing = [];
    if (!this.videoFile) {
      missing.push('videoFile');
    }
    if (!this.imageFile) {
      missing.push('imageFile');
    }
    if (!this.zipFile) {
      missing.push('zipFile');
    }
    if (this.device === '') {
      missing.push('device');
    }
    if (this.xGPS === '') {
      missing.push('xGPS');
    }
    if (this.yGPS === '') {
      missing.push('yGPS');
    }
    if (this.dir === '') {
      missing.push('dir');
    }
    if (!this.sdata) {
      missing.push('sdata');
    }
    if (!this.patches.some((patch) => patch.phenomena.length > 0)) {
      missing.push('patches');
    }
    return missing;
  }

  // Показваме маркировка по полетата само след първи неуспешен опит за
  // запис — преди това потребителят просто попълва формата необезпокояван.
  get missingFields() {
    return this.submitAttempted ? this.missingRequiredKeys : [];
  }

  focusField(key) {
    const element = document.getElementById(REQUIRED_FIELD_IDS[key]);
    if (!element) {
      return;
    }
    element.scrollIntoView({ behavior: 'smooth', block: 'center' });
    element.focus?.({ preventScroll: true });
  }

  @action
  async submit(event) {
    event.preventDefault();

    if (this.isSubmitting) {
      return;
    }

    this.error = null;
    this.success = null;

    const missing = this.missingRequiredKeys;
    if (missing.length > 0) {
      this.submitAttempted = true;
      this.focusField(missing[0]);
      return;
    }

    this.submitAttempted = false;
    this.isSubmitting = true;

    try {
      const formData = new FormData();

      if (this.videoFile) {
        formData.append('video', this.videoFile);
      }
      if (this.imageFile) {
        formData.append('image', this.imageFile);
      }
      if (this.zipFile) {
        formData.append('zip', this.zipFile);
      }

      const patchesPayload = [];
      for (const patch of this.patches) {
        if (patch.isEmpty) {
          continue;
        }

        patchesPayload.push({
          patch: patch.index,
          phenomena: patch.phenomena,
        });

        if (patch.txtFile) {
          formData.append(`patch_txt_${patch.index}`, patch.txtFile);
        }
      }

      const payload = {
        device: this.device === '' ? null : Number(this.device),
        cammod: this.cammod === '' ? null : Number(this.cammod),
        xGPS: this.xGPS === '' ? null : Number(this.xGPS),
        yGPS: this.yGPS === '' ? null : Number(this.yGPS),
        dir: this.dir === '' ? null : this.dir,
        sdata: toBackendDateTime(this.sdata),
        patches: patchesPayload,
      };

      formData.append('payload', JSON.stringify(payload));

      const result = await this.api.submitForm(
        '/api/videofile/create.php',
        formData,
      );

      this.reset();
      this.success = result;
    } catch (e) {
      this.error = e.message || 'Възникна грешка при запис.';
    } finally {
      this.isSubmitting = false;
    }
  }
}
