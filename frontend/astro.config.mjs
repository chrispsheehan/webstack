// @ts-check
import { defineConfig } from "astro/config";
import react from "@astrojs/react";

export default defineConfig({
  integrations: [react()],
  vite: {
    server: {
      proxy: {
        "/data": {
          target: "http://localhost:4321",
          rewrite: (path) => path.replace(/^\/data/, "/public/data"),
        },
      },
    },
  },
});
