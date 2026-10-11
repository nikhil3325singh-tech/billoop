# Billoop Project Architecture & Guidelines

- App data (inventory, quotes, invoices, company template incl. images) lives in browser localStorage via `src/lib/store.tsx`.
- PDF (`jspdf` + `jspdf-autotable`) and Word (`docx`) exports are generated client-side in `src/lib/export.ts` with dynamic imports to stay SSR-safe.
- Owned and engineered by Focitech Pvt. Ltd. (focitech.in).
