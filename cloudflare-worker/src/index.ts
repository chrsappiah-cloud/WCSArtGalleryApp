/**
 * WCS Art Gallery — edge prototype API (Cloudflare Worker).
 * Mirrors core /api routes used by the iOS client. Met import runs at the edge.
 * For production persistence, add D1 + migrations (see ../README or worker README).
 */

export interface Env {
  OPENAI_API_KEY?: string;
}

type ArtworkRow = {
  id: number;
  title: string;
  artist_name: string;
  description: string | null;
  medium: string | null;
  year: string | null;
  image_url: string;
  thumbnail_url: string | null;
  source_type: string;
  external_source: string | null;
  prompt_used: string | null;
  created_at: string;
};

const MET_SEARCH = "https://collectionapi.metmuseum.org/public/collection/v1/search";
const MET_OBJECT = "https://collectionapi.metmuseum.org/public/collection/v1/objects";

const json = (status: number, body: unknown, origin: string | null): Response =>
  new Response(JSON.stringify(body), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
      "cache-control": "no-store",
      ...corsHeaders(origin),
    },
  });

const corsHeaders = (origin: string | null): Record<string, string> => {
  const allow = origin && /^https?:\/\//.test(origin) ? origin : "*";
  return {
    "access-control-allow-origin": allow,
    "access-control-allow-methods": "GET,POST,OPTIONS",
    "access-control-allow-headers": "Content-Type, Authorization",
    "access-control-max-age": "86400",
  };
};

let seq = 1;
const memory: ArtworkRow[] = [
  {
    id: seq++,
    title: "Edge Seed — Kente Study",
    artist_name: "WCS Prototype",
    description: "Bundled with the Cloudflare Worker for offline-first demos.",
    medium: "Digital",
    year: "2026",
    image_url: "https://images.metmuseum.org/CRDImages/ad/original/DP251120.jpg",
    thumbnail_url: "https://images.metmuseum.org/CRDImages/ad/web-additional/DP251120.jpg",
    source_type: "prototype",
    external_source: null,
    prompt_used: null,
    created_at: new Date().toISOString(),
  },
];

const absolutize = (request: Request, pathOrUrl: string): string => {
  if (pathOrUrl.startsWith("http://") || pathOrUrl.startsWith("https://")) return pathOrUrl;
  if (pathOrUrl.startsWith("/")) {
    const u = new URL(request.url);
    return `${u.origin}${pathOrUrl}`;
  }
  return pathOrUrl;
};

const rowToResponse = (request: Request, r: ArtworkRow): ArtworkRow => ({
  ...r,
  image_url: absolutize(request, r.image_url),
  thumbnail_url: r.thumbnail_url ? absolutize(request, r.thumbnail_url) : null,
});

async function fetchMetSample(limit: number): Promise<ArtworkRow[]> {
  const search = await fetch(`${MET_SEARCH}?hasImages=true&q=${encodeURIComponent("african textiles")}`);
  if (!search.ok) throw new Error(`Met search ${search.status}`);
  const sjson = (await search.json()) as { objectIDs?: number[] };
  const ids = sjson.objectIDs ?? [];
  const out: ArtworkRow[] = [];
  for (const oid of ids.slice(0, limit)) {
    const o = await fetch(`${MET_OBJECT}/${oid}`);
    if (!o.ok) continue;
    const d = (await o.json()) as Record<string, unknown>;
    const image = (d.primaryImage as string) || (d.primaryImageSmall as string);
    if (!image) continue;
    out.push({
      id: seq++,
      title: String(d.title || "Untitled").slice(0, 512),
      artist_name: String(d.artistDisplayName || "The Met Open Access").slice(0, 512),
      description: [d.objectDate, d.culture].filter(Boolean).join(" — ").slice(0, 4096) || null,
      medium: d.medium ? String(d.medium).slice(0, 255) : null,
      year: d.objectDate ? String(d.objectDate).slice(0, 64) : null,
      image_url: image,
      thumbnail_url: (d.primaryImageSmall as string) || image,
      source_type: "external_api",
      external_source: `${MET_OBJECT}/${oid}`,
      prompt_used: null,
      created_at: new Date().toISOString(),
    });
  }
  return out;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const path = url.pathname.replace(/\/$/, "") || "/";
    const origin = request.headers.get("Origin");

    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: corsHeaders(origin) });
    }

    if (path === "/health" && request.method === "GET") {
      return json(200, { status: "ok" }, origin);
    }

    if (path === "/" && request.method === "GET") {
      return new Response(
        `<!DOCTYPE html><html><head><meta charset="utf-8"/><title>WCS Art Gallery Prototype</title></head>
        <body style="font-family:system-ui;background:#0a0a10;color:#e8e8f0;padding:2rem">
        <h1>WCS Art Gallery — edge API</h1>
        <p>Worker is live. iOS points <code>WCSWorkerAPIBaseURL</code> here (no <code>/api</code> suffix).</p>
        <ul>
          <li><code>GET /health</code></li>
          <li><code>GET /api/artworks</code></li>
          <li><code>POST /api/import/open-access-met-sample?limit=6</code></li>
          <li><code>POST /api/ai/prompt</code> (JSON body)</li>
        </ul>
        </body></html>`,
        { headers: { "content-type": "text/html; charset=utf-8", ...corsHeaders(origin) } },
      );
    }

    if (path === "/api/artworks" && request.method === "GET") {
      const rows = [...memory].reverse().map((r) => rowToResponse(request, r));
      return json(200, rows, origin);
    }

    if (path === "/api/import/open-access-met-sample" && request.method === "POST") {
      const limit = Number(url.searchParams.get("limit") || "6") || 6;
      try {
        const rows = await fetchMetSample(Math.min(20, limit));
        memory.push(...rows);
        return json(200, { imported: rows.length }, origin);
      } catch (e) {
        return json(502, { detail: String(e) }, origin);
      }
    }

    if (path === "/api/ai/prompt" && request.method === "POST") {
      const body = (await request.json().catch(() => null)) as Record<string, unknown> | null;
      const concept = String(body?.concept ?? "");
      const style = String(body?.style ?? "");
      const mood = String(body?.mood ?? "");
      const palette = String(body?.palette ?? "");
      const final = `Create an original artwork for a premium digital gallery. Subject: ${concept}. Style: ${style}. Mood: ${mood}. Palette: ${palette}.`;
      const system =
        "You are the World Class Scholars Art Engine. Return refined, gallery-grade language only.";
      return json(200, { system_prompt: system, final_prompt: final }, origin);
    }

    if (path === "/api/ai/generate" && request.method === "POST") {
      if (!env.OPENAI_API_KEY) {
        return json(503, { detail: "OPENAI_API_KEY is not configured on the Worker" }, origin);
      }
      return json(501, { detail: "Wire OpenAI Images from the Worker or proxy to FastAPI." }, origin);
    }

    return json(404, { detail: "Not found" }, origin);
  },
};
