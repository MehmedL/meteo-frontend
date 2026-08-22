import { pageTitle } from 'ember-page-title';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { LinkTo } from '@ember/routing';

<template>
  {{pageTitle "Регистрация"}}

  <section class="auth">
    {{#if @controller.success}}
      <div class="auth__card">
        <h2>Готово</h2>
        <p class="auth__hint">
          Акаунтът е създаден успешно. Вече можете да влезете.
        </p>
        <LinkTo @route="login" class="auth__button auth__button--link">
          Към вход
        </LinkTo>
      </div>
    {{else}}
      <form class="auth__card" {{on "submit" @controller.submit}}>
        <h2>Регистрация</h2>
        <p class="auth__hint">Създайте акаунт, за да използвате функциите на
          сайта.</p>

        <label class="auth__field">
          <span>Имейл</span>
          <input
            type="email"
            name="email"
            autocomplete="email"
            value={{@controller.email}}
            {{on "input" (fn @controller.updateField "email")}}
          />
        </label>

        <label class="auth__field">
          <span>Парола</span>
          <input
            type="password"
            name="password"
            autocomplete="new-password"
            value={{@controller.password}}
            {{on "input" (fn @controller.updateField "password")}}
          />
        </label>

        <label class="auth__field">
          <span>Тип достъп</span>
          <select {{on "change" @controller.setMode}}>
            <option value="window" selected={{@controller.isWindow}}>
              Времеви прозорец (от–до, макс. 10 дни)
            </option>
            <option value="count" selected={{@controller.isCount}}>
              Брой влизания
            </option>
          </select>
        </label>

        {{#if @controller.isWindow}}
          <div class="auth__row">
            <label class="auth__field">
              <span>Активен от</span>
              <input
                type="date"
                value={{@controller.from}}
                {{on "input" (fn @controller.updateField "from")}}
              />
            </label>
            <label class="auth__field">
              <span>Активен до</span>
              <input
                type="date"
                min={{@controller.toMin}}
                max={{@controller.toMax}}
                value={{@controller.to}}
                {{on "input" (fn @controller.updateField "to")}}
              />
            </label>
          </div>
        {{else}}
          <label class="auth__field">
            <span>Брой разрешени влизания</span>
            <input
              type="number"
              min="1"
              max="10"
              value={{@controller.nmax}}
              {{on "input" (fn @controller.updateField "nmax")}}
            />
          </label>
        {{/if}}

        <button
          type="submit"
          class="auth__button"
          disabled={{@controller.isDisabled}}
        >
          {{if @controller.isSubmitting "Създаване..." "Регистрация"}}
        </button>

        {{#if @controller.error}}
          <p class="auth__error" aria-live="polite">{{@controller.error}}</p>
        {{/if}}

        <p class="auth__switch">
          Вече имате акаунт?
          <LinkTo @route="login">Вход</LinkTo>
        </p>
      </form>
    {{/if}}
  </section>
</template>
