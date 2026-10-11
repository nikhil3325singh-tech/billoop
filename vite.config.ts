// TanStack Start configuration for Billoop (Focitech Pvt. Ltd.)
// Plugins included: TanStack router/start, react, tailwindcss, tsconfigPaths, nitro.
import { defineConfig } from "@lovable.dev/vite-tanstack-config";

export default defineConfig({
  tanstackStart: {
    // Redirect TanStack Start's bundled server entry to src/server.ts (our SSR error wrapper).
    // nitro/vite builds from this
    server: { entry: "server" },
  },
});
