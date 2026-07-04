import { pageTitle } from 'ember-page-title';
import { on } from '@ember/modifier';
import { LinkTo } from '@ember/routing';

<template>
  {{pageTitle "Вход"}}

  <section class="auth">
    <form class="auth__card" {{on "submit" @controller.submit}}>
      <h2>Вход</h2>
      <p class="auth__hint">Влезте, за да продължите към приложението.</p>

      <label class="auth__field">
        <span>Имейл</span>
        <input
          type="email"
          name="email"
          autocomplete="email"
          value={{@controller.email}}
          {{on "input" @controller.updateEmail}}
        />
      </label>

      <label class="auth__field">
        <span>Парола</span>
        <input
          type="password"
          name="password"
          autocomplete="current-password"
          value={{@controller.password}}
          {{on "input" @controller.updatePassword}}
        />
      </label>

      <button
        type="submit"
        class="auth__button"
        disabled={{@controller.isDisabled}}
      >
        {{if @controller.isSubmitting "Влизане..." "Вход"}}
      </button>

      {{#if @controller.error}}
        <p class="auth__error" aria-live="polite">✗ {{@controller.error}}</p>
      {{/if}}

      <p class="auth__switch">
        Нямате акаунт?
        <LinkTo @route="register">Регистрация</LinkTo>
      </p>
    </form>
  </section>
</template>
