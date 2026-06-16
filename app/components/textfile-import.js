import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';

// Дефинираме максималния размер (напр. 5MB в байтове)
const MAX_FILE_SIZE = 5 * 1024 * 1024;

export default class TextfileImport extends Component {
  @service api;

  @tracked file = null;
  @tracked isUploading = false;
  @tracked inserted = null;
  @tracked error = null;

  get isDisabled() {
    return this.isUploading || !this.file;
  }

  // Позволяваме подаване на динамичен URL, но запазваме стария като резервен
  get endpoint() {
    return this.args.endpoint ?? '/api/textfile/import.php';
  }

  @action
  selectFile(event) {
    const selectedFile = event.target.files?.[0];

    // Рестартираме съобщенията
    this.inserted = null;
    this.error = null;

    // Ако потребителят е натиснал "Cancel" в прозореца за избор
    if (!selectedFile) {
      this.file = null;
      return;
    }

    // 1. Проверка на типа файл
    if (
      selectedFile.type !== 'text/plain' &&
      !selectedFile.name.toLowerCase().endsWith('.txt')
    ) {
      this.error = 'Моля, изберете валиден текстов файл (.txt).';
      this.file = null;
      event.target.value = ''; // Изчистваме грешния файл от HTML инпута
      return;
    }

    // 2. Проверка на размера
    if (selectedFile.size > MAX_FILE_SIZE) {
      this.error = `Файлът е твърде голям. Максималният размер е 5MB.`;
      this.file = null;
      event.target.value = ''; // Изчистваме грешния файл от HTML инпута
      return;
    }

    // Ако всичко е наред, запазваме файла
    this.file = selectedFile;
  }

  @action
  async submit(event) {
    event.preventDefault();

    if (!this.file || this.isUploading) {
      return;
    }

    this.isUploading = true;
    this.inserted = null;
    this.error = null;

    try {
      const data = await this.api.upload(this.endpoint, this.file);
      this.inserted = data?.inserted ?? 0;

      // 3. Изчистване на формата след успешен импорт
      this.file = null;
      event.target.reset(); // Това нулира <form> и визуално маха името на файла

      this.args.onImported?.();
    } catch (e) {
      // Подсигуряваме се, че има текст за грешка, ако e.message липсва
      this.error = e.message || 'Възникна неочаквана грешка при качването.';
    } finally {
      this.isUploading = false;
    }
  }
}
