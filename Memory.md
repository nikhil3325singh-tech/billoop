# Memory

## Feature Index
- [Branding & Attribution (Focitech)](#feature-branding--attribution-focitech) - done
- [Document Export Engine (PDF & Word)](#feature-document-export-engine-pdf--word) - done
- [Authentication & Supabase Integration](#feature-authentication--supabase-integration) - done
- [Workspace & App Shell](#feature-workspace--app-shell) - done

---

## Feature: Branding & Attribution (Focitech)
- Status: done
- Purpose: Eliminate third-party watermarks/telemetry and establish complete copyright, branding, and legal ownership for Focitech Pvt. Ltd. (focitech.in).
- Files:
  - `src/components/Marketing.tsx`
  - `src/components/AppShell.tsx`
  - `src/routes/__root.tsx`
  - `src/lib/error-reporting.ts`
  - `README.md`
  - `AGENTS.md`
- Behavior / key decisions:
  - Removed third-party tracking scripts, preview message brokers, and telemetry headers.
  - Replaced error reporting with clean development-gated logging via `src/lib/error-reporting.ts`.
  - Added explicit copyright and website references pointing to `focitech.in` and `support@focitech.in`.
- Config / env: `SITE_URL="https://billop.focitech.in"`, `VITE_SITE_URL="https://billop.focitech.in"`.
- Known issues / TODO: Configure Supabase Auth Site URL and Redirect URLs for `https://billop.focitech.in/**`.
- Last changed: 2026-10-11 - Configured custom domain `billop.focitech.in` across environment, OpenGraph, canonical links, and project metadata.

---

## Feature: Document Export Engine (PDF & Word)
- Status: done
- Purpose: Client-side generation of GST quotations and invoices in PDF and Microsoft Word (.docx) formats with company letterhead and signature.
- Files:
  - `src/lib/export.ts`
  - `src/lib/calc.ts`
  - `src/lib/store.tsx`
- Behavior / key decisions:
  - SSR-safe dynamic imports of `jspdf`, `jspdf-autotable`, and `docx`.
  - Added official footer attribution: `Generated via Billoop • A Product of Focitech Pvt. Ltd. (focitech.in) • All rights reserved.`.
  - Generates file names deterministically from doc number and sanitized client name.
- Config / env: Client-side in browser; no server config needed.
- Known issues / TODO: None.
- Last changed: 2026-10-05 - Added Focitech rights and attribution footer in exported documents.

---

## Feature: Authentication & Supabase Integration
- Status: done
- Purpose: User authentication and session persistence for cloud accounts with local storage fallback.
- Files:
  - `src/integrations/supabase/client.ts`
  - `src/integrations/supabase/client.server.ts`
  - `src/integrations/supabase/auth-middleware.ts`
  - `src/integrations/supabase/cron-auth.ts`
  - `src/lib/auth.tsx`
  - `supabase/migrations/20261005_init_schema.sql`
- Behavior / key decisions:
  - Replaced preview postMessage iframe broker with standard browser `localStorage`.
  - Cleared external cloud-auth dependencies from `package.json`.
  - Updated cron authorization to rely on standard `CRON_SECRET`.
  - Handled strict optional property types for auth sign up flows.
  - Provided comprehensive PostgreSQL migration script with full Row Level Security (RLS), cascading foreign keys, performance indexes, and automatic onboarding triggers (`handle_new_user`).
- Config / env: `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `VITE_SUPABASE_URL`, `VITE_SUPABASE_PUBLISHABLE_KEY`.
- Known issues / TODO: Execute the SQL script in Supabase Dashboard SQL Editor for project `axfdafqlbvaiadslkanr`.
- Last changed: 2026-10-05 - Generated initial Supabase SQL schema migration with RLS, triggers, and seed data.

---

## Feature: Workspace & App Shell
- Status: done
- Purpose: Responsive application shell containing navigation, company switcher, and route rendering.
- Files:
  - `src/components/AppShell.tsx`
  - `src/routes/_authenticated/dashboard.tsx`
  - `src/routes/_authenticated/company.tsx`
- Behavior / key decisions:
  - Fixed TypeScript interface for navigation items.
  - Sticky sidebar navigation on desktop with responsive layout for tablet and mobile.
  - Sidebar footer displays Focitech ownership with link to `focitech.in`.
- Config / env: None required.
- Known issues / TODO: None.
- Last changed: 2026-10-05 - Fixed typing, removed non-Route component exports from route files to restore automatic TanStack Router code-splitting, and updated sidebar footer attribution to focitech.in.
