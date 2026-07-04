import { pageTitle } from 'ember-page-title';

<template>
  {{pageTitle "Начало"}}

  <section class="page">
    <div class="welcome">
      <h2>{{@controller.greeting}}</h2>
      <p class="welcome__text">
      </p>
    </div>
  </section>
</template>
