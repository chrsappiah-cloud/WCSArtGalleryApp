# WCS Art Gallery — Cloudflare Worker (prototype API)

Edge-hosted API compatible with the iOS app’s `GET /api/artworks`, Met import, and `POST /api/ai/prompt`. Data is **in-memory per isolate** (fine for demos); for production, add **D1** and bind it in `wrangler.toml`.

## Local

```bash
cd cloudflare-worker
npm install
npm run dev
```

Default dev URL: `http://127.0.0.1:8787`. Set the iOS `WCSWorkerAPIBaseURL` Info.plist key to that origin (no `/api` suffix).

## Deploy

```bash
npx wrangler login
npm run deploy
```

Copy the printed `*.workers.dev` URL into `WCSWorkerAPIBaseURL` for Release builds. Add your App Store / custom domain to **CORS** if you restrict origins (currently permissive for prototypes).

## Secrets (optional)

```bash
npx wrangler secret put OPENAI_API_KEY
```

`POST /api/ai/generate` is stubbed until you wire OpenAI or proxy to your FastAPI backend.

## CloudKit

The iOS app syncs a **snapshot** of artworks to the user’s **private** CloudKit database (backup / cross-device). Configure the **iCloud** container in Apple Developer and match `CloudKitGallerySync.containerIdentifier` in code.
