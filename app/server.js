// server.js
// ---------------------------------------------
// A minimal Node.js server for DevOps practice
// This app will be containerized with Docker
// and orchestrated in later stages of the apprenticeship.
// ---------------------------------------------

const http = require("http");

const PORT = process.env.PORT || 3000; // configurable via environment variable

// Create a simple HTTP server
const server = http.createServer((req, res) => {
    if (req.url === "/health") {
        // Health endpoint for container monitoring
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ status: "ok" }));
    } else {
        // Default route
        res.writeHead(200, { "Content-Type": "text/plain" });
        res.end("Hello DevOps Apprentice 👋\n");
    }
});

// Start listening
server.listen(PORT, () => {
    console.log(`🚀 Server is running on port ${PORT}`);
});
