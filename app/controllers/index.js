import Controller from '@ember/controller';

const COLUMNS = [
  { key: 'id', label: 'ID' },
  { key: 'device', label: 'Устройство' },
  { key: 'sdate', label: 'Дата' },
  { key: 'dir', label: 'Посока' },
  { key: 'xGPS', label: 'X GPS' },
  { key: 'yGPS', label: 'Y GPS' },
  { key: 'cammod', label: 'Режим' },
  { key: 'filepath', label: 'Видео' },
  { key: 'imgfile', label: 'Изображение' },
  { key: 'zipfile', label: 'ZIP' },
];

export default class IndexController extends Controller {
  columns = COLUMNS;

  get rows() {
    return this.model ?? [];
  }
}
