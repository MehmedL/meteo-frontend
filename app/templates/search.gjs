import { pageTitle } from 'ember-page-title';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { modifier } from 'ember-modifier';
import { filterMeasurementsByRanges } from 'meteo-frontend/controllers/search';

const closeOnOutsideClick = modifier((element, [close]) => {
  function handleClick(event) {
    if (!element.contains(event.target)) {
      close();
    }
  }
  document.addEventListener('click', handleClick, true);
  return () => document.removeEventListener('click', handleClick, true);
});

function includesId(list, id) {
  return list.includes(id);
}

function phenomNames(list) {
  return (list ?? []).map((p) => p.phenom).join(', ');
}

function eq(a, b) {
  return a === b;
}

function eqStr(a, b) {
  return String(a) === String(b);
}

function detailFor(detailById, id) {
  return detailById[id];
}

const MEASUREMENT_COLUMNS = [
  { key: 'frame', label: 'Frame' },
  { key: 'avR', label: 'avR' },
  { key: 'avG', label: 'avG' },
  { key: 'avB', label: 'avB' },
  { key: 'avDCP', label: 'avDCP' },
  { key: 'dvR', label: 'dvR' },
  { key: 'dvG', label: 'dvG' },
  { key: 'dvB', label: 'dvB' },
  { key: 'dvDCP', label: 'dvDCP' },
  { key: 'intens', label: 'Intens' },
  { key: 'satur', label: 'Satur' },
  { key: 'stHUE', label: 'stHUE' },
  { key: 'stxCCT', label: 'stxCCT' },
  { key: 'styCCT', label: 'styCCT' },
  { key: 'stCCT', label: 'stCCT' },
  { key: 'stCCTal', label: 'stCCTal' },
  { key: 'bktHUE', label: 'bktHUE' },
  { key: 'bkxCCT', label: 'bkxCCT' },
  { key: 'bkyCCT', label: 'bkyCCT' },
  { key: 'bkCCT', label: 'bkCCT' },
  { key: 'bkCCTal', label: 'bkCCTal' },
  { key: 'dav', label: 'Dav' },
  { key: 'ddev', label: 'Ddev' },
  { key: 'dcct', label: 'Dcct' },
];

function measurementValue(measurement, key) {
  return measurement[key];
}

<template>
  {{pageTitle "Търсене"}}

  <section class="page">
    <form class="import" {{on "submit" @controller.search}}>
      <header class="import__header">
        <h2 class="import__title">Търсене на записи</h2>
      </header>

      <section class="import__section" aria-labelledby="search-filters-heading">
        <h3 id="search-filters-heading" class="import__section-title">
          Устройство и явления
        </h3>
        <p class="import__section-desc">По избор — оставете празни, за да не
          филтрирате по тях. За явления може да изберете няколко (записът
          трябва да съдържа поне едно от избраните).</p>
        <div class="search__filters-row">
          <div class="import__field">
            <span class="import__label">Устройство</span>
            <select
              class="import__control"
              aria-label="Устройство"
              {{on "change" (fn @controller.updateField "device")}}
            >
              <option value="" selected={{eqStr @controller.device ""}}>
                — всички —
              </option>
              {{#each @controller.devices as |d|}}
                <option
                  value={{d.id}}
                  selected={{eqStr @controller.device d.id}}
                >
                  {{d.device}}
                </option>
              {{/each}}
            </select>
          </div>

          <div class="import__field">
            <span class="import__label">Посока</span>
            <select
              class="import__control"
              aria-label="Посока"
              {{on "change" (fn @controller.updateField "dir")}}
            >
              <option value="" selected={{eqStr @controller.dir ""}}>
                — всички —
              </option>
              {{#each @controller.directions as |d|}}
                <option value={{d}} selected={{eqStr @controller.dir d}}>
                  {{d}}
                </option>
              {{/each}}
            </select>
          </div>

          <div class="import__field">
            <span class="import__label">Дата</span>
            <input
              type="date"
              class="import__control"
              value={{@controller.sdataDate}}
              {{on "input" (fn @controller.updateField "sdataDate")}}
            />
          </div>

          <div class="import__field">
            <span class="import__label">Час</span>
            {{#if @controller.timeFilterEnabled}}
              <div class="search__range">
                <input
                  type="time"
                  class="import__control"
                  value={{@controller.sdataTime}}
                  {{on "input" (fn @controller.updateField "sdataTime")}}
                />
                <button
                  type="button"
                  class="import__secondary"
                  {{on "click" @controller.toggleTimeFilter}}
                >
                  Без час
                </button>
              </div>
            {{else}}
              <button
                type="button"
                class="import__secondary"
                {{on "click" @controller.toggleTimeFilter}}
              >
                + Добави час
              </button>
            {{/if}}
          </div>

          <div class="import__field">
            <span class="import__label">Явления</span>
            <div
              class="search__dropdown"
              {{closeOnOutsideClick @controller.closePhenomena}}
            >
              <button
                type="button"
                class="import__control search__dropdown-toggle"
                aria-haspopup="listbox"
                aria-expanded={{if @controller.phenomenaOpen "true" "false"}}
                {{on "click" @controller.togglePhenomenaOpen}}
              >
                <span>{{@controller.selectedPhenomLabel}}</span>
                <span
                  class="search__group-chevron
                    {{if
                      @controller.phenomenaOpen
                      'search__group-chevron--open'
                    }}"
                >▾</span>
              </button>
              {{#if @controller.phenomenaOpen}}
                <div class="search__dropdown-panel" role="listbox">
                  {{#each @controller.phenomena as |phenom|}}
                    <label class="search__dropdown-option">
                      <input
                        type="checkbox"
                        checked={{includesId
                          @controller.selectedPhenomIds
                          phenom.id
                        }}
                        {{on "change" (fn @controller.togglePhenomenon phenom.id)}}
                      />
                      <span>{{phenom.phenom}}</span>
                    </label>
                  {{/each}}
                </div>
              {{/if}}
            </div>
          </div>
        </div>
      </section>

      <section class="import__section" aria-labelledby="search-txt-heading">
        <h3 id="search-txt-heading" class="import__section-title">Параметри
          (textfile)</h3>
        <p class="import__section-desc">По избор — оставете празно, за да не
          филтрирате по дадения параметър. Разгънете раздел, за да зададете
          диапазон.</p>
        <div class="search__groups">
          {{#each @controller.columnGroups as |group|}}
            <div class="search__group">
              <button
                type="button"
                class="search__group-header"
                aria-expanded={{if group.isOpen "true" "false"}}
                {{on "click" (fn @controller.toggleGroup group)}}
              >
                <span class="search__group-title">{{group.title}}</span>
                {{#if group.activeCount}}
                  <span class="search__group-badge">{{group.activeCount}}</span>
                {{/if}}
                <span class="search__group-chevron
                  {{if group.isOpen 'search__group-chevron--open'}}">▾</span>
              </button>
              {{#if group.isOpen}}
                <div class="import__meta search__group-body">
                  {{#each group.columns as |col|}}
                    <div class="import__field">
                      <span class="import__label">{{col.key}}</span>
                      <div class="search__range">
                        <input
                          type="text"
                          inputmode="decimal"
                          class="import__control"
                          placeholder="мин"
                          value={{col.min}}
                          {{on
                            "input"
                            (fn @controller.updateColumnBound col "min")
                          }}
                        />
                        <input
                          type="text"
                          inputmode="decimal"
                          class="import__control"
                          placeholder="макс"
                          value={{col.max}}
                          {{on
                            "input"
                            (fn @controller.updateColumnBound col "max")
                          }}
                        />
                      </div>
                    </div>
                  {{/each}}
                </div>
              {{/if}}
            </div>
          {{/each}}
        </div>
      </section>

      <footer class="import__actions">
        {{#if @controller.error}}
          <p class="import__error" aria-live="polite">
            {{@controller.error}}</p>
        {{/if}}
        <button
          type="button"
          class="import__secondary"
          disabled={{@controller.noActiveFilters}}
          {{on "click" @controller.clearFilters}}
        >
          Изчисти филтрите
        </button>
        <button
          type="button"
          class="import__secondary"
          disabled={{@controller.exportDisabled}}
          {{on "click" @controller.exportExcel}}
        >
          {{if @controller.isExporting "Изготвяне..." "Износ в Excel"}}
        </button>
        <button
          type="submit"
          class="import__button"
          disabled={{@controller.searchDisabled}}
        >
          {{if @controller.isSearching "Търсене..." "Търси"}}
        </button>
      </footer>
    </form>

    {{#if @controller.hasSearched}}
      <div class="data">
        <h3>Резултати ({{@controller.total}})</h3>
        {{#if @controller.results.length}}
          <div class="data__scroll">
            <table class="data__table">
              <thead>
                <tr>
                  <th></th>
                  <th>Устройство</th>
                  <th>Дата и час</th>
                  <th>Посока</th>
                  <th>X</th>
                  <th>Y</th>
                  <th>Явления</th>
                </tr>
              </thead>
              <tbody>
                {{#each @controller.results as |row|}}
                  <tr>
                    <td>
                      <button
                        type="button"
                        class="detail__toggle
                          {{if
                            (eq @controller.expandedId row.id)
                            'detail__toggle--open'
                          }}"
                        aria-expanded={{if
                          (eq @controller.expandedId row.id)
                          "true"
                          "false"
                        }}
                        title="Пълни данни за записа"
                        {{on "click" (fn @controller.toggleDetail row.id)}}
                      >▾</button>
                    </td>
                    <td>{{row.deviceName}}</td>
                    <td>{{row.sdata}}</td>
                    <td>{{row.dir}}</td>
                    <td>{{row.xGPS}}</td>
                    <td>{{row.yGPS}}</td>
                    <td>{{phenomNames row.phenomena}}</td>
                  </tr>
                  {{#if (eq @controller.expandedId row.id)}}
                    <tr class="detail__row">
                      <td colspan="10">
                        {{#if (eq @controller.detailLoadingId row.id)}}
                          <p class="detail__status">Зареждане...</p>
                        {{else if @controller.detailError}}
                          <p class="detail__status detail__status--error">
                            {{@controller.detailError}}</p>
                        {{else}}
                          {{#let
                            (detailFor @controller.detailById row.id)
                            as |detail|
                          }}
                            {{#if detail.patches.length}}
                              <div class="detail__patches">
                                {{#each detail.patches as |patch|}}
                                  <div class="detail__patch">
                                    <div class="detail__patch-head">
                                      <span class="detail__patch-title">Пач
                                        {{patch.patch}}</span>
                                      <span class="detail__patch-phenoms">
                                        {{#if patch.phenomena.length}}
                                          {{phenomNames patch.phenomena}}
                                        {{else}}
                                          без явления
                                        {{/if}}
                                      </span>
                                    </div>
                                    {{#let
                                      (filterMeasurementsByRanges
                                        patch.measurements
                                        @controller.appliedRanges
                                      )
                                      as |measurements|
                                    }}
                                      {{#if measurements.length}}
                                        <div class="detail__measurements-scroll">
                                          <table
                                            class="detail__measurements-table"
                                          >
                                            <thead>
                                              <tr>
                                                {{#each
                                                  MEASUREMENT_COLUMNS
                                                  as |col|
                                                }}
                                                  <th>{{col.label}}</th>
                                                {{/each}}
                                              </tr>
                                            </thead>
                                            <tbody>
                                              {{#each
                                                measurements
                                                as |m|
                                              }}
                                                <tr>
                                                  {{#each
                                                    MEASUREMENT_COLUMNS
                                                    as |col|
                                                  }}
                                                    <td>{{measurementValue
                                                        m
                                                        col.key
                                                      }}</td>
                                                  {{/each}}
                                                </tr>
                                              {{/each}}
                                            </tbody>
                                          </table>
                                        </div>
                                      {{else if patch.measurements.length}}
                                        <p class="detail__status">Няма кадри,
                                          отговарящи на зададените
                                          диапазони.</p>
                                      {{else}}
                                        <p class="detail__status">Няма
                                          измервания.</p>
                                      {{/if}}
                                    {{/let}}
                                  </div>
                                {{/each}}
                              </div>
                            {{else}}
                              <p class="detail__status">Записът няма
                                пачове.</p>
                            {{/if}}
                          {{/let}}
                        {{/if}}
                      </td>
                    </tr>
                  {{/if}}
                {{/each}}
              </tbody>
            </table>
          </div>
        {{else}}
          <p class="data__empty">Няма намерени записи.</p>
        {{/if}}
      </div>
    {{/if}}
  </section>
</template>
