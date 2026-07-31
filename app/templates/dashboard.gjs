import { pageTitle } from 'ember-page-title';
import { modifier } from 'ember-modifier';

const setBarWidth = modifier((element, [pct]) => {
  element.style.width = `${pct}%`;
});

<template>
  {{pageTitle "Статистика"}}

  <section class="page">
    <div class="stats__totals">
      <div class="stats__total">
        <span class="stats__total-value">{{@controller.totals.videofiles}}</span>
        <span class="stats__total-label">Видео записа</span>
      </div>
      <div class="stats__total">
        <span class="stats__total-value">{{@controller.totals.devices}}</span>
        <span class="stats__total-label">Устройства</span>
      </div>
      <div class="stats__total">
        <span class="stats__total-value">{{@controller.totals.phenomena}}</span>
        <span class="stats__total-label">Видове явления</span>
      </div>
    </div>

    <div class="stats__panels">
      <div class="data stats__panel">
        <h3>Записи по явление</h3>
        {{#if @controller.byPhenomenon.length}}
          <div class="stats__bars">
            {{#each @controller.byPhenomenon as |row|}}
              <div class="stats__bar-row">
                <span class="stats__bar-label">{{row.phenom}}</span>
                <div class="stats__bar-track">
                  <div class="stats__bar-fill" {{setBarWidth row.pct}}></div>
                </div>
                <span class="stats__bar-value">{{row.count}}</span>
              </div>
            {{/each}}
          </div>
        {{else}}
          <p class="data__empty">Няма данни.</p>
        {{/if}}
      </div>

      <div class="data stats__panel">
        <h3>Записи по устройство</h3>
        {{#if @controller.byDevice.length}}
          <div class="stats__bars">
            {{#each @controller.byDevice as |row|}}
              <div class="stats__bar-row">
                <span class="stats__bar-label">{{row.device}}</span>
                <div class="stats__bar-track">
                  <div
                    class="stats__bar-fill stats__bar-fill--alt"
                    {{setBarWidth row.pct}}
                  ></div>
                </div>
                <span class="stats__bar-value">{{row.count}}</span>
              </div>
            {{/each}}
          </div>
        {{else}}
          <p class="data__empty">Няма данни.</p>
        {{/if}}
      </div>
    </div>
  </section>
</template>
