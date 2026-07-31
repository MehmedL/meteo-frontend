import { pageTitle } from 'ember-page-title';
import { LinkTo } from '@ember/routing';
import AccountMenu from 'meteo-frontend/components/account-menu';

<template>
  {{pageTitle "MeteoFrontend"}}

  <header class="app-header">
    <div class="app-header__inner">
      <LinkTo @route="index" class="app-header__title">
        <h1>Метеорологични явления</h1>
      </LinkTo>

      <div class="app-header__actions">
        {{#if @controller.session.canAccessApp}}
          <LinkTo @route="index" class="app-header__link">Начало</LinkTo>
          <LinkTo @route="search" class="app-header__link">Извличане на данни</LinkTo>
          <LinkTo @route="dashboard" class="app-header__link">Статистика</LinkTo>
        {{/if}}
        <AccountMenu @onLogout={{@controller.logout}} />
      </div>
    </div>
  </header>

  <main class="app-main">
    {{outlet}}
  </main>

  {{#if @controller.showFooter}}
    <footer class="app-footer">
      <p class="app-footer__text">Авторски колектив: Ивайло Атанасов, Боряна Пачеджиева, Добринка Петрова, Петя Павлова.<br />© Център за компетентност „Интелигентни мехатронни, eко- и енергоспестяващи системи и технологии“.</p>
    </footer>
  {{/if}}
</template>
