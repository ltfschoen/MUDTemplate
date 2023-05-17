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
      // methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE', 'OPTIONS'],
      methods: "*",
      // allowedHeaders: ['Content-Type', 'Authorization'],
      allowedHeaders: "*",
      credentials: true,
      // exposedHeaders: ['Content-Range', 'X-Content-Range'],
      exposedHeaders: "*",
      // preflightContinue: true,
      // optionsSuccessStatus: 204
    },
    // hmr: {
    //   clientPort: 8545,
    //   port: 3000,
    //   overlay: true,
    // }
    // proxy: {
    //   '/socket.io': {
    //     target: 'ws://127.0.0.1:8545',
    //     ws: true,
    //   },
    // },
    // strictPort: false,
  },
  build: {
    target: "es2022",
  },
});
