# Billoop

> Professional Quotations, Inventory & GST Billing Platform for Electrical Contractors and Panel Builders.  
> Developed and maintained by **[Focitech Pvt. Ltd.](https://focitech.in)**.

---

## Overview

Billoop is a modern web application designed specifically for electrical sector contractors, panel fabricators, and equipment suppliers. It streamlines the lifecycle of quotation drafting, inventory tracking, margin computation, and GST-compliant tax invoicing, offering one-click exports in both PDF and Microsoft Word (`.docx`) formats.

## Key Features

- **Electrical Item Master & Inventory**: Catalog wires, switches, circuit breakers, panels, and custom labor items with HSN codes, default rates, and tax slabs (5%, 12%, 18%, 28%).
- **Interactive Quotation Builder**: Quick line item addition, real-time discount calculations, SGST/CGST/IGST split computations, and terms customization.
- **Tax Invoices**: Convert accepted quotes directly into official GST tax invoices with round-off and automated amount in words.
- **Custom Company Branding**: Upload your business logo, authorized digital signature, official rubber stamp, and full letterhead.
- **Client-Side Export Engine**: Generate crisp, print-ready PDF and editable Word (`.docx`) documents with branded letterheads and compliance footnotes.
- **Modern Responsive Design**: Fluid mobile and desktop user interface engineered for shop-floor and back-office usage.

## Tech Stack

- **Framework**: TanStack Start & React 19
- **Routing & State**: TanStack Router & React Query
- **Styling**: Tailwind CSS & Lucide Icons
- **Document Generation**: jsPDF, jspdf-autotable, and docx
- **Backend / Authentication**: Supabase (Client-side localStorage fallback for offline/instant mode)
- **Runtime & Deployment**: Nitro (Cloudflare Workers / Node / Vercel compatible)

## Getting Started

### Prerequisites

- Node.js 20+ or Bun
- npm, pnpm, or bun

### Installation

```bash
git clone https://github.com/nikhil3325singh-tech/billoop-.git
cd billoop-
npm install
```

### Environment Variables

Copy the example environment configuration:

```bash
cp .env.example .env
```

Set the following variables if connecting to Supabase:

```env
SUPABASE_URL="https://your-project.supabase.co"
SUPABASE_PUBLISHABLE_KEY="your-anon-key"
VITE_SUPABASE_URL="https://your-project.supabase.co"
VITE_SUPABASE_PUBLISHABLE_KEY="your-anon-key"
```

### Local Development

Start the local development server:

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Building for Production

```bash
npm run build
npm run preview
```

## Architecture

```
billoop/
├── public/                 # Static assets, logos, and favicon
├── src/
│   ├── components/         # Reusable UI & layout elements (AppShell, Marketing, Dialogs)
│   ├── integrations/       # Supabase client & authentication helpers
│   ├── lib/                # Core business logic, pricing calculations, storage, export engines
│   └── routes/             # File-based routes for dashboard, inventory, quotes, invoices, and settings
└── vite.config.ts          # Vite & Nitro compilation configuration
```

## Ownership & License

Copyright © 2026 **[Focitech Pvt. Ltd.](https://focitech.in)**. All rights reserved.  
For enterprise inquiries or custom deployments, contact [support@focitech.in](mailto:support@focitech.in).
