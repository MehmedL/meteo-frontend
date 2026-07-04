import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import FileDrop from 'meteo-frontend/components/file-drop';

function includesId(list, id) {
  return list.includes(id);
}

// Един пач: избор на явления (много) + един .txt файл.
// Аргументи: @patch, @phenomena, @onToggle, @onSelectTxt, @onToggleCollapse
<template>
  <div class="patch {{if @patch.collapsed 'patch--collapsed'}}">
    <button
      type="button"
      class="patch__header"
      aria-expanded={{if @patch.collapsed "false" "true"}}
      {{on "click" (fn @onToggleCollapse @patch)}}
    >
      <span class="patch__title">Пач {{@patch.index}}</span>
      <span class="patch__summary">{{@patch.summary}}</span>
      <span class="patch__chevron" aria-hidden="true"></span>
    </button>

    {{#unless @patch.collapsed}}
      <div class="patch__body">
        <div class="patch__phenomena">
          <span class="patch__subtitle">Явления</span>
          <div class="patch__pills">
            {{#each @phenomena as |phenom|}}
              <label class="patch__pill">
                <input
                  type="checkbox"
                  class="patch__pill-input"
                  checked={{includesId @patch.phenomena phenom.id}}
                  {{on "change" (fn @onToggle @patch phenom.id)}}
                />
                <span class="patch__pill-text">{{phenom.phenom}}</span>
              </label>
            {{/each}}
          </div>
        </div>

        <FileDrop
          @label="Текстов файл"
          @accept=".txt,text/plain"
          @file={{@patch.txtFile}}
          @onSelect={{fn @onSelectTxt @patch}}
          @compact={{true}}
        />
      </div>
    {{/unless}}
  </div>
</template>
