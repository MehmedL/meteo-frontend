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
          {{#if @controller.onDataRoute}}
            <LinkTo @route="index" class="app-header__link">Начало</LinkTo>
          {{else}}
            <LinkTo @route="search" class="app-header__link">Извличане на данни</LinkTo>
          {{/if}}
        {{/if}}
        <AccountMenu @onLogout={{@controller.logout}} />
      </div>
    </div>
  </header>

  <main class="app-main">
    {{outlet}}
  </main>
</template>
