import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';

function formatSize(bytes) {
  if (bytes >= 1024 * 1024 * 1024) {
    return `${(bytes / (1024 * 1024 * 1024)).toFixed(1)} GB`;
  }
  if (bytes >= 1024 * 1024) {
    return `${Math.round(bytes / (1024 * 1024))} MB`;
  }
  return `${Math.ceil(bytes / 1024)} KB`;
}

function matchesAccept(file, accept) {
  if (!accept) {
    return true;
  }

  const name = file.name.toLowerCase();
  const type = (file.type || '').toLowerCase();

  return accept
    .split(',')
    .map((pattern) => pattern.trim().toLowerCase())
    .filter(Boolean)
    .some((pattern) => {
      if (pattern.startsWith('.')) {
        return name.endsWith(pattern);
      }
      if (pattern.endsWith('/*')) {
        return type.startsWith(pattern.slice(0, -1));
      }
      return type === pattern;
    });
}

export default class FileDrop extends Component {
  @tracked isDragOver = false;
  @tracked validationError = null;
  inputId = `file-drop-${Math.random().toString(36).slice(2, 9)}`;

  get fileName() {
    return this.args.file?.name ?? '';
  }

  get isCompact() {
    return Boolean(this.args.compact);
  }

  // @maxSize (bytes) е по избор — подава се от родителския компонент,
  // за да съвпада с лимита, който backend-ът реално налага за този тип файл.
  select(file) {
    if (!matchesAccept(file, this.args.accept)) {
      this.validationError = 'Неподдържан тип файл.';
      return;
    }

    if (this.args.maxSize && file.size > this.args.maxSize) {
      this.validationError = `Файлът е твърде голям (максимум ${formatSize(this.args.maxSize)}).`;
      return;
    }

    this.validationError = null;
    this.args.onSelect?.(file);
  }

  @action
  onChange(event) {
    const file = event.target.files?.[0] ?? null;
    if (file) {
      this.select(file);
    }
  }

  @action
  onDrop(event) {
    event.preventDefault();
    this.isDragOver = false;
    const file = event.dataTransfer?.files?.[0] ?? null;
    if (file) {
      this.select(file);
    }
  }

  @action
  onDragOver(event) {
    event.preventDefault();
    this.isDragOver = true;
  }

  @action
  onDragLeave(event) {
    event.preventDefault();
    this.isDragOver = false;
  }

  @action
  clear(event) {
    event.preventDefault();
    event.stopPropagation();
    this.validationError = null;
    this.args.onSelect?.(null);
  }

  <template>
    <div
      id={{@id}}
      class="filedrop
        {{if this.isCompact 'filedrop--compact'}}
        {{if @invalid 'filedrop--invalid'}}"
      tabindex={{if @invalid "-1"}}
    >
      {{#unless this.isCompact}}
        <span class="filedrop__label">{{@label}}</span>
      {{/unless}}

      <label
        for={{this.inputId}}
        class="filedrop__zone {{if this.isDragOver 'filedrop__zone--over'}}"
        title={{@label}}
        {{on "dragover" this.onDragOver}}
        {{on "dragenter" this.onDragOver}}
        {{on "dragleave" this.onDragLeave}}
        {{on "drop" this.onDrop}}
      >
        {{#if this.fileName}}
          <span class="filedrop__name">{{this.fileName}}</span>
          <button
            type="button"
            class="filedrop__clear"
            aria-label="Премахни файл"
            {{on "click" this.clear}}
          ><span aria-hidden="true">×</span></button>
        {{else if this.isCompact}}
          <span class="filedrop__hint">{{@label}} — щракнете или пуснете</span>
        {{else}}
          <span class="filedrop__hint">Пуснете файл тук или щракнете за избор</span>
        {{/if}}

        <input
          id={{this.inputId}}
          type="file"
          accept={{@accept}}
          class="filedrop__input"
          aria-label={{@label}}
          {{on "change" this.onChange}}
        />
      </label>

      {{#if this.validationError}}
        <p class="filedrop__error" role="alert">{{this.validationError}}</p>
      {{/if}}
    </div>
  </template>
}
