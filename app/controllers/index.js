import Controller from '@ember/controller';
import { service } from '@ember/service';

export default class IndexController extends Controller {
  @service session;

  get greeting() {
    const name = this.session.currentUser?.user;
    return name ? `Добре дошли, ${name}!` : 'Добре дошли!';
  }
}
