import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    host: true, // allows access from Docker
    // port: 3000, // change default port
    strictPort: true, // fail instead of falling back to another port
  },
});
