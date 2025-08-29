// server.js (ESM)
// ---------------------------------------------
// Minimal HTTP server for DevOps practice
// Containerized in Day 1–4; will be wired into CI/CD.
// ---------------------------------------------

import http from 'node:http';
import process from 'node:process';

const PORT = Number(process.env.PORT) || 3000;

// Create a simple HTTP server
const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok' }));
    return;
  }

  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello DevOps Apprentice 👋\n');
});

// Start listening
server.listen(PORT, () => {
  console.log(`🚀 Server is running on port ${PORT}`);
});
