// ESLint 9 flat config (ESM) for a Node + Jest project
import js from '@eslint/js';
import globals from 'globals';
import jest from 'eslint-plugin-jest';

export default [
  // Start from ESLint's recommended rules
  js.configs.recommended,

  // Project rules
  {
    files: ['**/*.js', '**/*.mjs'],
    ignores: ['node_modules/**', 'dist/**', 'jest.config.*'],
    languageOptions: {
      ecmaVersion: 2021,
      sourceType: 'module',
      globals: {
        ...globals.node, // process, __dirname, etc.
        ...globals.jest, // test, expect, beforeAll, etc.
      },
    },
    plugins: { jest },
    rules: {
      // Bring in Jest's recommended rules
      ...(jest.configs.recommended?.rules ?? {}),
      // add your custom rules here
    },
  },
];
