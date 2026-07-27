import Controller from '@ember/controller';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { DIRECTIONS } from 'meteo-frontend/controllers/import';

export const TXT_COLUMN_GROUPS = [
  { key: 'avg', columns: ['avR', 'avG', 'avB', 'avDCP'] },
  { key: 'dev', columns: ['dvR', 'dvG', 'dvB', 'dvDCP'] },
  { key: 'intensity', columns: ['Intens', 'Satur'] },
  { key: 'street', columns: ['stHUE', 'stxCCT', 'styCCT', 'stCCT', 'stCCTal'] },
  {
    key: 'background',
    columns: ['bktHUE', 'bkxCCT', 'bkyCCT', 'bkCCT', 'bkCCTal'],
  },
  { key: 'delta', columns: ['Dav', 'Ddev', 'Dcct'] },
  { key: 'misc', columns: ['Frame'] },
];

const RANGE_KEY_TO_MEASUREMENT_KEY = {
  Frame: 'frame',
  Intens: 'intens',
  Satur: 'satur',
  Dav: 'dav',
  Ddev: 'ddev',
  Dcct: 'dcct',
};

function measurementMatchesRanges(measurement, ranges) {
  return ranges.every(({ key, min, max }) => {
    const value = measurement[key];
    if (value === undefined || value === null) {
      return false;
    }
    if (min !== null && value < min) {
      return false;
    }
    if (max !== null && value > max) {
      return false;
    }
    return true;
  });
}

export function filterMeasurementsByRanges(measurements, ranges) {
  if (!ranges || ranges.length === 0) {
    return measurements;
  }

  return measurements.filter((m) => measurementMatchesRanges(m, ranges));
}

class ColumnFilter {
  key;
  @tracked min = '';
  @tracked max = '';

  constructor(key) {
    this.key = key;
  }
}

class ColumnGroup {
  key;
  columns;
  @tracked isOpen = false;

  constructor(key, columnKeys) {
    this.key = key;
    this.columns = columnKeys.map((columnKey) => new ColumnFilter(columnKey));
  }

  get title() {
    return this.columns.map((c) => c.key).join(', ');
  }

  get activeCount() {
    return this.columns.filter((c) => c.min !== '' || c.max !== '').length;
  }
}

export default class SearchController extends Controller {
  @service api;

  directions = DIRECTIONS;

  @tracked devices = [];
  @tracked device = '';
  @tracked dir = '';
  @tracked sdataDate = '';
  @tracked sdataTime = '';
  @tracked timeFilterEnabled = false;
  @tracked phenomena = [];
  @tracked selectedPhenomIds = [];
  @tracked phenomenaOpen = false;
  columnGroups = TXT_COLUMN_GROUPS.map(
    (group) => new ColumnGroup(group.key, group.columns),
  );

  get columnFilters() {
    return this.columnGroups.flatMap((group) => group.columns);
  }

  get hasActiveFilters() {
    return (
      this.device !== '' ||
      this.dir !== '' ||
      this.sdataDate !== '' ||
      this.selectedPhenomIds.length > 0 ||
      this.columnFilters.some((column) => column.min !== '' || column.max !== '')
    );
  }

  get noActiveFilters() {
    return !this.hasActiveFilters;
  }

  get searchDisabled() {
    return this.isSearching || this.noActiveFilters;
  }

  get exportDisabled() {
    return this.isExporting || this.noActiveFilters;
  }

  get selectedPhenomCount() {
    return this.selectedPhenomIds.length;
  }

  get selectedPhenomLabel() {
    if (this.selectedPhenomCount === 0) {
      return '— всички —';
    }
    return `${this.selectedPhenomCount} избрани`;
  }

  @tracked appliedRanges = [];

  @tracked results = [];
  @tracked total = 0;
  @tracked isSearching = false;
  @tracked isExporting = false;
  @tracked error = null;
  @tracked hasSearched = false;

  @tracked expandedId = null;
  @tracked detailById = {};
  @tracked detailLoadingId = null;
  @tracked detailError = null;

  @action
  updateField(field, event) {
    this[field] = event.target.value;
  }

  @action
  togglePhenomenon(id) {
    if (this.selectedPhenomIds.includes(id)) {
      this.selectedPhenomIds = this.selectedPhenomIds.filter((p) => p !== id);
    } else {
      this.selectedPhenomIds = [...this.selectedPhenomIds, id];
    }
  }

  @action
  togglePhenomenaOpen() {
    this.phenomenaOpen = !this.phenomenaOpen;
  }

  @action
  closePhenomena() {
    this.phenomenaOpen = false;
  }

  @action
  updateColumnBound(column, bound, event) {
    column[bound] = event.target.value.replace(',', '.').replace(/[^0-9.-]/g, '');
  }

  @action
  toggleGroup(group) {
    group.isOpen = !group.isOpen;
  }

  @action
  toggleTimeFilter() {
    this.timeFilterEnabled = !this.timeFilterEnabled;
    if (!this.timeFilterEnabled) {
      this.sdataTime = '';
    }
  }

  @action
  clearFilters() {
    this.device = '';
    this.dir = '';
    this.sdataDate = '';
    this.sdataTime = '';
    this.timeFilterEnabled = false;
    this.selectedPhenomIds = [];
    this.phenomenaOpen = false;
    for (const column of this.columnFilters) {
      column.min = '';
      column.max = '';
    }
  }

  @action
  async toggleDetail(id) {
    if (this.expandedId === id) {
      this.expandedId = null;
      return;
    }

    this.expandedId = id;
    this.detailError = null;

    if (this.detailById[id]) {
      return;
    }

    this.detailLoadingId = id;
    try {
      const data = await this.api.get(
        `/api/videofile/detail.php?id=${id}`,
      );
      this.detailById = { ...this.detailById, [id]: data };
    } catch (e) {
      this.detailError = e.message || 'Грешка при зареждане на детайли.';
      this.expandedId = null;
    } finally {
      this.detailLoadingId = null;
    }
  }

  buildSearchParams() {
    const params = new URLSearchParams();
    if (this.device !== '') {
      params.set('device', this.device);
    }
    if (this.dir !== '') {
      params.set('dir', this.dir);
    }
    if (this.sdataDate !== '') {
      if (this.timeFilterEnabled && this.sdataTime !== '') {
        params.set('sdata_from', `${this.sdataDate} ${this.sdataTime}:00`);
        params.set('sdata_to', `${this.sdataDate} ${this.sdataTime}:59`);
      } else {
        params.set('sdata_from', `${this.sdataDate} 00:00:00`);
        params.set('sdata_to', `${this.sdataDate} 23:59:59`);
      }
    }
    for (const id of this.selectedPhenomIds) {
      params.append('phenom[]', id);
    }

    for (const column of this.columnFilters) {
      if (column.min === '' && column.max === '') {
        continue;
      }
      if (column.min !== '') {
        params.set(`${column.key}_min`, column.min);
      }
      if (column.max !== '') {
        params.set(`${column.key}_max`, column.max);
      }
    }

    return params;
  }

  @action
  async search(event) {
    event?.preventDefault();

    if (this.noActiveFilters) {
      this.error = 'Изберете поне един критерий за търсене.';
      return;
    }

    this.isSearching = true;
    this.error = null;
    this.expandedId = null;
    this.detailById = {};
    this.detailError = null;

    try {
      const params = this.buildSearchParams();

      this.appliedRanges = this.columnFilters
        .filter((column) => column.min !== '' || column.max !== '')
        .map((column) => ({
          key: RANGE_KEY_TO_MEASUREMENT_KEY[column.key] ?? column.key,
          min: column.min === '' ? null : Number(column.min),
          max: column.max === '' ? null : Number(column.max),
        }));

      const data = await this.api.get(
        `/api/videofile/index.php?${params.toString()}`,
      );

      this.results = data?.items ?? [];
      this.total = data?.total ?? 0;
      this.hasSearched = true;
    } catch (e) {
      this.error = e.message || 'Грешка при търсене.';
      this.results = [];
      this.total = 0;
    } finally {
      this.isSearching = false;
    }
  }

  @action
  async exportExcel() {
    if (this.noActiveFilters) {
      this.error = 'Изберете поне един критерий за търсене.';
      return;
    }

    this.isExporting = true;
    this.error = null;

    try {
      const params = this.buildSearchParams();
      const blob = await this.api.getBlob(
        `/api/videofile/export.php?${params.toString()}`,
      );

      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = `videofile_export_${Date.now()}.xlsx`;
      document.body.appendChild(link);
      link.click();
      link.remove();
      URL.revokeObjectURL(url);
    } catch (e) {
      this.error = e.message || 'Грешка при износ.';
    } finally {
      this.isExporting = false;
    }
  }
}
