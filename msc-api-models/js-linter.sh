#!/bin/bash

ROOT_DIR=$1

if [ ! -f ".eslintignore" ]
then
  cat > $ROOT_DIR/.eslintignore << EOF
node_modules
test
tests
EOF
fi

if [ ! -f ".eslintrc.json" ]
then
  cat > $ROOT_DIR/.eslintrc.json << EOF
{
  "env": {
    "es2020": true
  },
  "plugins": ["sonarjs"],
  "rules": {
    "indent": ["error", 2],
    "linebreak-style": 0,
    "quotes": ["error", "single"],
    "semi": ["error", "always"],
    "class-methods-use-this": ["off"],
    "no-magic-numbers": [
      "error",
      {
        "ignore": [1],
        "ignoreArrayIndexes": true,
        "enforceConst": true,
        "detectObjects": false
      }
    ],
    "no-console": ["off"],
    "no-param-reassign": ["off"],
    "consistent-return": ["off"],
    "no-undef": ["off"],
    "max-len": [
      "error",
      {
        "code": 90,
        "ignoreComments": true,
        "ignoreUrls": true
      }
    ],
    "max-params": ["error", 4],
    "max-lines": ["error", 250],
    "max-lines-per-function": ["error", 150],
    "complexity": ["error", 15],
    "object-curly-newline": ["off"],
    "import/no-extraneous-dependencies": ["off"],
    "sonarjs/cognitive-complexity": ["error", 15],
    "sonarjs/no-collapsible-if": ["error"],
    "sonarjs/no-collection-size-mischeck": ["error"],
    "sonarjs/no-duplicate-string": ["error", 5],
    "sonarjs/no-duplicated-branches": ["error"],
    "sonarjs/no-extra-arguments": ["error"],
    "sonarjs/no-identical-conditions": ["error"],
    "sonarjs/no-identical-expressions": ["error"],
    "sonarjs/no-identical-functions": ["error"],
    "sonarjs/no-inverted-boolean-check": ["error"],
    "sonarjs/no-one-iteration-loop": ["error"],
    "sonarjs/no-redundant-boolean": ["error"],
    "sonarjs/no-unused-collection": ["error"],
    "sonarjs/no-use-of-empty-return-value": ["error"],
    "sonarjs/no-useless-catch": ["error"],
    "sonarjs/prefer-object-literal": ["error"],
    "sonarjs/prefer-single-boolean-return": ["error"]
  }
}
EOF
fi