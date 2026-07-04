import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { LinkTo } from '@ember/routing';
import { service } from '@ember/service';

export default class AccountMenu extends Component {
  @service session;
  @tracked isOpen = false;

  @action
  toggle() {
    this.isOpen = !this.isOpen;
  }

  @action
  close() {
    this.isOpen = false;
  }

  @action
  async logout() {
    this.close();
    await this.args.onLogout?.();
  }

  <template>
    <div class="account">
      <button type="button" class="account__trigger" aria-label="Профил" aria-haspopup="true" aria-expanded={{if this.isOpen "true" "false"}} {{on "click" this.toggle}}>
        <svg class="account__icon" viewBox="0 0 24 24" width="24" height="24" aria-hidden="true">
          <circle cx="12" cy="8" r="4" fill="currentColor" />
          <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
        </svg>
      </button>

      {{#if this.isOpen}}
        <div class="account__menu">
          {{#if this.session.isAuthenticated}}
            <button type="button" class="account__item account__item--button" {{on "click" this.logout}}>
              Изход
            </button>
            {{#if this.session.isAdmin}}
            <LinkTo @route="import" class="account__item" {{on "click" this.close}}>
              Качване
            </LinkTo>
            {{/if}}
          {{else}}
            <LinkTo @route="login" class="account__item" {{on "click" this.close}}>
              Вход
            </LinkTo>
            <LinkTo @route="register" class="account__item" {{on "click" this.close}}>
              Регистрация
            </LinkTo>
          {{/if}}
        </div>
      {{/if}}
    </div>
  </template>
}
