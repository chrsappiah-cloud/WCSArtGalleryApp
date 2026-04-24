import base64
import uuid
from pathlib import Path

from openai import OpenAI

from app.core.config import settings

client = OpenAI(api_key=settings.openai_api_key) if settings.openai_api_key else None

SYSTEM_PROMPT = """
You are the World Class Scholars Art Engine.
Your role is to turn a user concept into a refined, gallery-grade image prompt.
Do not imitate living artists, copyrighted characters, or brand styles.
Prefer original, exhibition-quality language with clear subject, composition, materiality, light, and mood.
Return only the final image prompt when asked.
""".strip()


def build_prompt(concept: str, style: str, mood: str, palette: str) -> str:
    return (
        f"Create an original artwork concept for a premium digital gallery. "
        f"Subject: {concept}. Style direction: {style}. Mood: {mood}. "
        f"Palette: {palette}. Composition should feel curated, high-end, and exhibition-ready. "
        f"Avoid logos, watermarks, copyrighted characters, and text overlays."
    )


def generate_image(prompt: str, size: str = '1024x1024') -> tuple[str, str | None]:
    if not client:
        raise RuntimeError('OPENAI_API_KEY is not configured')
    result = client.images.generate(
        model=settings.openai_image_model,
        prompt=prompt,
        size=size,
    )
    item = result.data[0]

    if getattr(item, "b64_json", None):
        raw = base64.b64decode(item.b64_json)
        out_dir = Path(settings.media_root) / "generated"
        out_dir.mkdir(parents=True, exist_ok=True)
        path = out_dir / f"{uuid.uuid4().hex}.png"
        path.write_bytes(raw)
        return str(path.resolve()), None

    if getattr(item, "url", None):
        return "", item.url

    raise RuntimeError("Image response contained neither b64_json nor url")
