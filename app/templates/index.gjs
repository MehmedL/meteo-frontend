import { pageTitle } from 'ember-page-title';
import patchDiagram from 'meteo-frontend/assets/images/patch.png';
import mistImage from 'meteo-frontend/assets/images/mist.jpg';
import calculating from 'meteo-frontend/assets/images/calculating.jpg';
import sql from 'meteo-frontend/assets/images/sql.jpg';
import color from 'meteo-frontend/assets/images/color.jpg';

<template>
  {{pageTitle "Начало"}}

  <section class="page">

    <div class="zigzag">
      <div class="zigzag__row">
        <div class="zigzag__text">
          <h3 class="zigzag__title">База данни</h3>
          <p class="zigzag__body">Базата данни е разработена в лабораторията за „Обработка на визуална информация в интелигентните транспортни системи“ от Лабораторен комплекс „Разпределени системи и интелигентни сензорни мрежи“ в Технически университет - София, филиал Пловдив част от Център за компетентност „Интелигентни мехатронни, eко- и енергоспестяващи системи и технологии“. Данните се отнасят за природни обекти, променящи се при различни метеорологични условия.</p>
        </div>
        <div class="zigzag__media">
          <img
            src={{mistImage}}
            alt="Път през гора, обвита в гъста мъгла"
            class="zigzag__image zigzag__image--cover"
          />
        </div>
      </div>

      <div class="zigzag__row zigzag__row--reverse">
        <div class="zigzag__text">
          <h3 class="zigzag__title">Съдържание на базата</h3>
          <p class="zigzag__body">Всеки запис включва видео файл, JPG изображение с маркирани пачове и текстови файлове с изчислени параметри за всеки кадър:</p>
          <ul class="zigzag__list">
            <li><strong>video files</strong> — клипове при различни метеорологични явления: ясно небе, облаци, дъжд, мъгла, сняг и др.</li>
            <li><strong>JPG files</strong> — изображения с позициите на анализираните пачове</li>
            <li><strong>TXT in ZIP files</strong> — параметри по кадри за всеки видео файл</li>
            <li><strong>Objects_on_thy_sky_*.xlsx</strong> — устройство за запис, GPS координати, дата/час и пачове с конкретен обект</li>
          </ul>
        </div>
        <div class="zigzag__media">
          <img
            src={{sql}}
            alt="Схема на база данни с таблици и връзки между тях"
            class="zigzag__image zigzag__image--cover"
          />
        </div>
      </div>

      <div class="zigzag__row">
        <div class="zigzag__text">
          <h3 class="zigzag__title">Пачове и разположение</h3>
          <p class="zigzag__body">Параметрите се изчисляват в 9 локални квадратни области (пачове), номерирани от 0 (централен) до 8 и разположени симетрично на 0°, 45°, 90°, 135°, 180°, 225°, 270° и 315° спрямо центъра на кадъра. Размерът на пача се определя автоматично според по-малкия размер на изображението: PatchSize = 32, 64, 128 или 256 пиксела.</p>
        </div>
        <div class="zigzag__media">
          <img
            src={{patchDiagram}}
            alt="Диаграма на разположението на 9-те пача в кадъра"
            class="zigzag__image"
          />
        </div>
      </div>

      <div class="zigzag__row zigzag__row--reverse">
        <div class="zigzag__text">
          <h3 class="zigzag__title">Изчислявани параметри</h3>
          <p class="zigzag__body">За всеки пач се изчисляват средни стойности и девиация за R, G, B и DCP (dark channel prior), интензитет, наситеност и цветови тон (hue) в HSV системата.</p>
        </div>
        <div class="zigzag__media">
          <img
            src={{calculating}}
            alt="Изчисляване на цветови параметри в пач от кадъра"
            class="zigzag__image zigzag__image--cover"
          />
        </div>
      </div>

      <div class="zigzag__row">
        <div class="zigzag__text">
          <h3 class="zigzag__title">Цветова температура (CCT)</h3>
          <p class="zigzag__body">Корелираната цветова температура се пресмята по два независими метода — чрез координатите на цветовия локус (x, y) и чрез помощните координати (u, v) — както за цвета на пача, така и за подсветката (DCP).</p>
        </div>
        <div class="zigzag__media">
           <img
            src={{color}}
            alt="Визуализация на цветова температура (CCT)"
            class="zigzag__image zigzag__image--cover"
          />
        </div>
      </div>
    </div>
  </section>
</template>
