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

      <AccountMenu @onLogout={{@controller.logout}} />
    </div>
  </header>

  <main class="app-main">
    {{outlet}}
  </main>
</template>
