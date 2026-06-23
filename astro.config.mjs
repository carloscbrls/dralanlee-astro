import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://dralanlee.com',
  integrations: [sitemap({
    lastmod: new Date(),
  })],
  compressHTML: true,
  build: {
    inlineStylesheets: 'auto',
  },
});
