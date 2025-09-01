// server.js (ESM)
// ---------------------------------------------
// Minimal HTTP server for DevOps practice
// Containerized in Day 1–4; will be wired into CI/CD.
// ---------------------------------------------

import http from 'node:http';

export function makeServer() {
  return http.createServer((req, res) => {
    if (req.url === '/health') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ status: 'ok' }));
      return;
    }
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Hello DevOps Apprentice 👋\n');
  });
}

const PORT = process.env.PORT || 3000;
if (process.env.NODE_ENV !== 'test') {
  const server = makeServer();
  server.listen(PORT, () =>
    console.log(`🚀 Server is running on port ${PORT}`)
  );
}
