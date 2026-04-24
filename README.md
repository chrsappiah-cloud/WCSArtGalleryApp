# World Class Scholars Art Gallery

Full-stack starter for a premium art gallery platform with:

- SwiftUI iOS app
- FastAPI backend
- Local image upload and external API ingestion
- OpenAI-powered prompt orchestration and image generation
- Curated showcase and exhibition-style browsing

## Structure

- **WCSArtGalleryApp.xcodeproj + mocks** — default iOS design: open `WCSArtGalleryApp.xcodeproj`, sources in `WCSArtGalleryApp/`, gallery data from `MockGalleryService`
- **`WCSArtGalleryApp/WorldClassScholarsArtGallery/`** — FastAPI / fusion-PDF client linked **in the same app target** (extra **Backend** tab). Duplicate PDF copy also under `ios/WorldClassScholarsArtGallery/` for reference only
- `WCSArtGalleryApp.xcodeproj` at repo root
- `backend/` FastAPI service (`app/main.py`, `app/services/openai_service.py`, …)
- `cloudflare-worker/` optional edge-hosted API (Wrangler) for the same iOS routes
- `docs/implementation-report.md` implementation report

## Quick start

### Backend

Use **Python 3.11 or 3.12** (recommended for dependency wheels).

```bash
cd backend
cp .env.example .env
python3.12 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Edit `.env` and set `OPENAI_API_KEY` when you use image generation. Use **`OPENAI_IMAGE_MODEL`** (`gpt-image-1.5`, `gpt-image-1`, `dall-e-3`, …); sizes are mapped per model. Generated files are always stored under **`media/generated/`** (even when OpenAI returns a temporary URL). Set **`PUBLIC_BASE_URL`** (no trailing slash) if clients reach the API through a tunnel, a deployed host, or your Mac’s LAN IP so `/media/...` links resolve correctly on a physical device. If you change SQL columns, delete **`backend/wcs_gallery.db`** once so `create_all` can recreate the schema.

**Automated checks (backend):** use Python **3.12** (`python3.12 -m venv .venv`), then `pip install -r requirements-dev.txt` and `pytest tests/ -q`. The bundled `.venv` may be **3.14**, which cannot install pinned `pydantic-core`; recreate the venv on 3.12 locally or rely on **GitHub Actions** (`.github/workflows/wcs-backend-tests.yml`).

### iOS

**WCSArtGalleryApp.xcodeproj + mocks** (default design): Open **`WCSArtGalleryApp.xcodeproj`**. The app target syncs the whole **`WCSArtGalleryApp/`** folder (Xcode file-system synchronized group). **Home / Explore / Saved** use **`CompositeGalleryService`** (API first, then mocks). The **Studio** tab runs the fusion stack from **`WCSArtGalleryApp/WorldClassScholarsArtGallery/`** against **`WCSBackendAPIConfig`**, which reads **`WCSWorkerAPIBaseURL`** from **`Info.plist`** (scheme origin only, no `/api` suffix). Defaults to `http://127.0.0.1:8000` (FastAPI); set `http://127.0.0.1:8787` when using **`cloudflare-worker`** (`npm run dev`), or your deployed `https://…workers.dev` URL for a hosted prototype. On device, use HTTPS or add **ATS** exceptions for plain HTTP as needed.

**`ios/WorldClassScholarsArtGallery/`** holds the original PDF export paths; the linked-in implementation lives under **`WCSArtGalleryApp/WorldClassScholarsArtGallery/`** with `WCSBackend*` type names to avoid clashing with mock models.

**Cloudflare Worker:** see **`cloudflare-worker/README.md`** — edge API (`/api/artworks`, Met import, AI prompt) with `npm run deploy`.

**CloudKit:** **Profile → iCloud** backs up / merges gallery snapshots to the private database (`CloudKitGallerySync`, container **`iCloud.wcs.WCSArtGalleryApp`** in entitlements). Create the container and enable **iCloud + CloudKit** for the App ID in Apple Developer if operations fail.

**Automated checks (iOS):** in Xcode, **⌘U** runs **WCSArtGalleryAppTests** (Swift Testing + **SLO-style** `XCTAssertLessThan` budgets in `PerformanceBudgets.swift` for JSON decode + mock fetch loops, plus `XCTMeasure` for local baselines) and **WCSArtGalleryAppUITests** (tab bar). GitHub Actions on every PR and on `main`: **iOS build + unit tests**, **backend pytest**, **Cloudflare Worker `npm run typecheck`**. To require green checks before merge, follow **`docs/github-branch-protection.md`**. For production-grade performance, pair these budgets with **Instruments** and **MetricKit** on Release builds.
