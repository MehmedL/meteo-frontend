import Controller from '@ember/controller';

function withPercentages(rows, key) {
  const max = Math.max(1, ...rows.map((row) => row[key]));
  return rows.map((row) => ({ ...row, pct: Math.round((row[key] / max) * 100) }));
}

export default class DashboardController extends Controller {
  get totals() {
    return this.model?.totals ?? { videofiles: 0, devices: 0, phenomena: 0 };
  }

  get byPhenomenon() {
    return withPercentages(this.model?.byPhenomenon ?? [], 'count');
  }

  get byDevice() {
    return withPercentages(this.model?.byDevice ?? [], 'count');
  }
}
