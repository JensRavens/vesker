import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig({
  plugins: [
    RubyPlugin(),
  ],
  // Minify CSS with esbuild, not lightningcss: lightningcss drops modern features
  // (e.g. `view-transition-name` / `::view-transition-*`) for the broad browserslist.
  build: {
    cssMinify: 'esbuild',
  },
})
