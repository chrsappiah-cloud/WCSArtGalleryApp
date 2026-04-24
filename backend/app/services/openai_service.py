import base64
import uuid
from pathlib import Path

import httpx
from openai import OpenAI
from openai import OpenAIError

from app.core.config import settings

SYSTEM_PROMPT = """
You are the World Class Scholars Art Engine.
Your role is to turn a user concept into a refined, gallery-grade image prompt.
Do not imitate living artists, copyrighted characters, or brand styles.
Prefer original, exhibition-quality language with clear subject, composition, materiality, light, and mood.
Return only the final image prompt when asked.
""".strip()

# Sizes accepted by GPT image models (images.generations).
GPT_IMAGE_SIZES = frozenset({"1024x1024", "1536x1024", "1024x1536", "auto"})
DALLE3_SIZES = frozenset({"1024x1024", "1792x1024", "1024x1792"})
DALLE2_SIZES = frozenset({"256x256", "512x512", "1024x1024"})


def normalize_image_size(model: str, requested: str) -> str:
    """Map client aspect_ratio to a size string valid for the configured OpenAI image model."""
    m = (model or "").strip().lower()
    r = (requested or "").strip().lower() or "1024x1024"

    if m == "dall-e-3":
        if r in DALLE3_SIZES:
            return r
        if r == "1536x1024":
            return "1792x1024"
        if r == "1024x1536":
            return "1024x1792"
        return "1024x1024"

    if m == "dall-e-2":
        if r in DALLE2_SIZES:
            return r
        return "1024x1024"

    if r in GPT_IMAGE_SIZES:
        return r
    if r in {"1792x1024", "1024x1792"}:
        return "1024x1024"
    return "1024x1024"


def build_prompt(concept: str, style: str, mood: str, palette: str) -> str:
    return (
        f"Create an original artwork concept for a premium digital gallery. "
        f"Subject: {concept}. Style direction: {style}. Mood: {mood}. "
        f"Palette: {palette}. Composition should feel curated, high-end, and exhibition-ready. "
        f"Avoid logos, watermarks, copyrighted characters, and text overlays."
    )


def _client() -> OpenAI:
    if not settings.openai_api_key:
        raise RuntimeError("OPENAI_API_KEY is not configured")
    return OpenAI(api_key=settings.openai_api_key)


def _write_png_bytes(data: bytes) -> str:
    out_dir = Path(settings.media_root) / "generated"
    out_dir.mkdir(parents=True, exist_ok=True)
    path = out_dir / f"{uuid.uuid4().hex}.png"
    path.write_bytes(data)
    return str(path.resolve())


def _persist_remote_image(url: str) -> str:
    """DALL-E URLs expire; always persist bytes under media/generated for stable gallery URLs."""
    with httpx.Client(timeout=120.0, follow_redirects=True) as client:
        response = client.get(url)
        response.raise_for_status()
        return _write_png_bytes(response.content)


def generate_image(prompt: str, size: str = "1024x1024") -> tuple[str, str | None]:
    model = settings.openai_image_model
    normalized_size = normalize_image_size(model, size)
    kwargs: dict = {
        "model": model,
        "prompt": prompt,
        "size": normalized_size,
        "n": 1,
    }
    try:
        result = _client().images.generate(**kwargs)
    except TypeError:
        # Older SDKs may reject explicit `n` for some models — retry without it.
        kwargs.pop("n", None)
        try:
            result = _client().images.generate(**kwargs)
        except OpenAIError as exc:
            raise RuntimeError(f"OpenAI image generation failed: {exc}") from exc
    except OpenAIError as exc:
        raise RuntimeError(f"OpenAI image generation failed: {exc}") from exc

    if not result.data:
        raise RuntimeError("OpenAI returned no image data")

    item = result.data[0]

    if getattr(item, "b64_json", None):
        raw = base64.b64decode(item.b64_json)
        path = _write_png_bytes(raw)
        return path, None

    if getattr(item, "url", None):
        path = _persist_remote_image(item.url)
        return path, None

    raise RuntimeError("Image response contained neither b64_json nor url")
