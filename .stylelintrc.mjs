export default {
  extends: ['stylelint-config-standard'],
  rules: {
    // Позволяваме BEM именуване: block__element--modifier
    'selector-class-pattern': [
      '^[a-z]([a-z0-9]*)(-[a-z0-9]+)*(__([a-z0-9]+)(-[a-z0-9]+)*)?(--([a-z0-9]+)(-[a-z0-9]+)*)?$',
      {
        message:
          'Очаква се клас в BEM формат (block__element--modifier, kebab-case)',
      },
    ],
  },
};
