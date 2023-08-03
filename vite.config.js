import { defineConfig } from 'vite'
import { createVuePlugin as vue } from "vite-plugin-vue2"; // to use vue 2

// https://vitejs.dev/config/
const path = require("path");

export default defineConfig({
  publicPath: "./",
  outputDir: "dist",
  assetsDir: "static",
  plugins: [vue()],
  resolve: {
    extensions: ['.mjs', '.js', '.ts', '.jsx', '.tsx', '.json', '.vue'],
    alias: {
      "@": path.resolve(__dirname, "./src"), // allows for @ alias https://vueschool.io/articles/vuejs-tutorials/how-to-migrate-from-vue-cli-to-vite/
    },
  },
});