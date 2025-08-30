/* eslint-disable no-undef */
/**
 * ESLint config for a Node (ESM) app.
 * - Enables Node globals (process, Buffer, etc.)
 * - Uses modern JS and module source type
 * - Ignores config/build directories so ESLint doesn't lint itself
 */
module.exports = {
  root: true,
  env: {
    node: true,
    es2021: true,
  },
  parserOptions: {
    ecmaVersion: 2021,
    sourceType: 'module', // we use ESM ("type":"module")
  },
  extends: ['eslint:recommended'],
  ignorePatterns: [
    'node_modules/**',
    'dist/**',
    '.eslintrc.*',
    'eslint.config.*',
  ],
  rules: {
    // keep it minimal; add stricter rules later
  },
};
