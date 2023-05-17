import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    fs: {
      strict: false,
    },
        cors: {
          // origin: ["ws://127.0.0.1:8545/", "http://127.0.0.1:8545/", "http://localhost:3000/"],
          origin: "*",
          methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE', 'OPTIONS'],
          allowedHeaders: ['Content-Type', 'Authorization'],
          exposedHeaders: ['Content-Range', 'X-Content-Range'],
          preflightContinue: true,
          optionsSuccessStatus: 204
        },
  },
  build: {
    target: "es2022",
  },
});
