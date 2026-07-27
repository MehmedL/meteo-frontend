import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';

export default class FileDrop extends Component {
  @tracked isDragOver = false;
  inputId = `file-drop-${Math.random().toString(36).slice(2, 9)}`;

  get fileName() {
    return this.args.file?.name ?? '';
  }

  get isCompact() {
    return Boolean(this.args.compact);
  }

  @action
  onChange(event) {
    const file = event.target.files?.[0] ?? null;
    this.args.onSelect?.(file);
  }

  @action
  onDrop(event) {
    event.preventDefault();
    this.isDragOver = false;
    const file = event.dataTransfer?.files?.[0] ?? null;
    if (file) {
      this.args.onSelect?.(file);
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
    this.args.onSelect?.(null);
  }

  <template>
    <div class="filedrop {{if this.isCompact 'filedrop--compact'}}">
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
          >
          </button>
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
    </div>
  </template>
}
