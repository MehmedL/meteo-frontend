import { pageTitle } from 'ember-page-title';

<template>
  {{pageTitle "MeteoFrontend"}}
  <h2 id="title">Welcome to Ember</h2>

  <section class="api-check">
    <h3>Тест на връзката Ember ↔ PHP</h3>
    {{#if @model.ok}}
      <p class="api-check__ok">✓ {{@model.message}}</p>
    {{else}}
      <p class="api-check__error">✗ Грешка: {{@model.error}}</p>
    {{/if}}
    <p class="api-check__url"><small>{{@model.url}}</small></p>
  </section>

  {{outlet}}
</template>
