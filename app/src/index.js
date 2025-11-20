const http = require('http');

const port = process.env.PORT || 8080;

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/plain; charset=utf-8'});
  res.end('Hello from Cloud Run!==20251120==');
});

server.listen(port, () => {
  console.log(`Server running at port ${port}`);
});
