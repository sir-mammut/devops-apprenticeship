// app/__tests__/app.test.js
import { makeServer } from '../server.js';

let server;
let baseURL;

beforeAll(async () => {
  server = makeServer();
  await new Promise((resolve) => {
    server.listen(0, '127.0.0.1', () => {
      const { port } = server.address();
      baseURL = `http://127.0.0.1:${port}`;
      resolve();
    });
  });
});

afterAll(async () => {
  await new Promise((resolve) => server.close(resolve));
});

test("GET /health returns {status:'ok'}", async () => {
  const res = await fetch(`${baseURL}/health`);
  expect(res.status).toBe(200);
  const json = await res.json();
  expect(json).toEqual({ status: 'ok' });
});
