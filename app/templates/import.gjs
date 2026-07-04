import { pageTitle } from 'ember-page-title';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import FileDrop from 'meteo-frontend/components/file-drop';
import PatchRow from 'meteo-frontend/components/patch-row';

function eq(a, b) {
  return String(a) === String(b);
}

<template>
  {{pageTitle "Импорт на видео"}}

  <section class="page">
    <form class="import" {{on "submit" @controller.submit}}>
      <header class="import__header">
        
        {{#if @controller.success}}
          <p class="import__ok" aria-live="polite">
            ✓ Записано успешно (видео #{{@controller.success.videofileId}},
            пачове:
            {{@controller.success.patches}}, явления:
            {{@controller.success.phenomena}}, редове:
            {{@controller.success.textrows}})
          </p>
        {{/if}}
      </header>

      <section class="import__section" aria-labelledby="import-files-heading">
        <h3 id="import-files-heading" class="import__section-title">Файлове</h3>
        <p class="import__section-desc">Видео, изображение и архив за записа.</p>
        <div class="import__grid">
          <FileDrop
            @label="Видео файл"
            @accept="video/*"
            @file={{@controller.videoFile}}
            @onSelect={{@controller.setVideo}}
          />
          <FileDrop
            @label="Изображение"
            @accept="image/*"
            @file={{@controller.imageFile}}
            @onSelect={{@controller.setImage}}
          />
          <FileDrop
            @label="Zip файл"
            @accept=".zip,application/zip"
            @file={{@controller.zipFile}}
            @onSelect={{@controller.setZip}}
          />
        </div>
      </section>

      <section class="import__section" aria-labelledby="import-meta-heading">
        <h3 id="import-meta-heading" class="import__section-title">Данни за
          записа</h3>
        <p class="import__section-desc">Устройство, координати и параметри на
          заснемане.</p>

        <div class="import__meta">
          <div class="import__field import__field--wide">
            <span class="import__label">Устройство</span>
            {{#unless @controller.showNewDevice}}
              <div class="import__inline import__reveal">
                <select
                  class="import__control"
                  aria-label="Устройство"
                  {{on "change" (fn @controller.updateField "device")}}
                >
                  <option value="" selected={{eq @controller.device ""}}>
                    — изберете —
                  </option>
                  {{#each @controller.devices as |d|}}
                    <option
                      value={{d.id}}
                      selected={{eq @controller.device d.id}}
                    >
                      {{d.device}}
                    </option>
                  {{/each}}
                </select>
                <button
                  type="button"
                  class="import__secondary"
                  {{on "click" @controller.toggleNewDevice}}
                >
                  Ново
                </button>
              </div>
            {{/unless}}

            {{#if @controller.showNewDevice}}
              <div class="import__inline import__reveal">
                <input
                  type="text"
                  class="import__control"
                  placeholder="Име на ново устройство"
                  aria-label="Име на ново устройство"
                  value={{@controller.newDeviceName}}
                  {{on "input" (fn @controller.updateField "newDeviceName")}}
                />
                <button
                  type="button"
                  class="import__secondary"
                  disabled={{@controller.addingDevice}}
                  {{on "click" @controller.addDevice}}
                >
                  {{if @controller.addingDevice "..." "Добави"}}
                </button>
                <button
                  type="button"
                  class="import__secondary"
                  {{on "click" @controller.toggleNewDevice}}
                >
                  Отказ
                </button>
              </div>
            {{/if}}
          </div>

          <label class="import__field">
            <span class="import__label">X (GPS)</span>
            <input
              type="number"
              step="any"
              class="import__control"
              value={{@controller.xGPS}}
              {{on "input" (fn @controller.updateField "xGPS")}}
            />
          </label>

          <label class="import__field">
            <span class="import__label">Y (GPS)</span>
            <input
              type="number"
              step="any"
              class="import__control"
              value={{@controller.yGPS}}
              {{on "input" (fn @controller.updateField "yGPS")}}
            />
          </label>

          <label class="import__field">
            <span class="import__label">Посока</span>
            <select
              class="import__control"
              {{on "change" (fn @controller.updateField "dir")}}
            >
              <option value="" selected={{eq @controller.dir ""}}>—</option>
              {{#each @controller.directions as |d|}}
                <option
                  value={{d}}
                  selected={{eq @controller.dir d}}
                >{{d}}</option>
              {{/each}}
            </select>
          </label>

          <label class="import__field">
            <span class="import__label">Дата на записа</span>
            <input
              type="date"
              class="import__control"
              value={{@controller.sdata}}
              {{on "input" (fn @controller.updateField "sdata")}}
            />
          </label>

          <label class="import__field">
            <span class="import__label">Режим</span>
            <select
              class="import__control"
              {{on "change" (fn @controller.updateField "cammod")}}
            >
              <option value="" selected={{eq @controller.cammod ""}}>
                — изберете —
              </option>
              {{#each @controller.cameraModes as |m|}}
                <option value={{m.id}} selected={{eq @controller.cammod m.id}}>
                  {{m.mode}}
                </option>
              {{/each}}
            </select>
          </label>
        </div>
      </section>

      <section class="import__section" aria-labelledby="import-patches-heading">
        <div class="import__section-head">
          <div>
            <h3
              id="import-patches-heading"
              class="import__section-title"
            >Пачове</h3>
            <p class="import__section-desc">Явления и текстов файл за всеки пач
              (0–8).</p>
          </div>
          {{#if @controller.canAddPatch}}
            <button
              type="button"
              class="import__secondary import__add-patch"
              {{on "click" @controller.addPatch}}
            >
              + Добави пач
            </button>
          {{/if}}
        </div>

        <div class="import__patches">
          {{#each @controller.patches as |patch|}}
            <PatchRow
              @patch={{patch}}
              @phenomena={{@controller.phenomena}}
              @onToggle={{@controller.togglePhenomenon}}
              @onSelectTxt={{@controller.setPatchTxt}}
              @onToggleCollapse={{@controller.togglePatchCollapse}}
            />
          {{/each}}
        </div>
      </section>

      <footer class="import__actions">
        {{#if @controller.error}}
          <p class="import__error" aria-live="polite">✗
            {{@controller.error}}</p>
        {{/if}}
        <button
          type="submit"
          class="import__button"
          disabled={{@controller.isSubmitting}}
        >
          {{if @controller.isSubmitting "Запис..." "Запиши"}}
        </button>
      </footer>
    </form>
  </section>
</template>
