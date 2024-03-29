//simple websocket echo server
const express = require("express");
const WebSocket = require("ws");
const SocketServer = require("ws").Server;

const server = express().listen(8000);

const wss = new SocketServer({ server });

console.log("WS server listening on port 8000");

wss.on("connection", (ws) => {
  console.log("client conected");

  ws.on("close", () => {
    console.log("client disconected");
  });

  ws.on("message", (message) => {
    console.log("{recived message}  %s", message);

    wss.clients.forEach(function each(client) {
      if (client !== ws && client.readyState === WebSocket.OPEN) {
        client.send(message);
      }
    });
  });
});
