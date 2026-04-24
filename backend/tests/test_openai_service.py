"""Pure prompt logic; image generation requires a real API key."""

from app.services import openai_service as svc


def test_normalize_image_size_maps_dalle3_landscape():
    assert svc.normalize_image_size("dall-e-3", "1536x1024") == "1792x1024"
    assert svc.normalize_image_size("dall-e-3", "1024x1536") == "1024x1792"


def test_normalize_image_size_gpt_family_accepts_auto():
    assert svc.normalize_image_size("gpt-image-1.5", "auto") == "auto"
    assert svc.normalize_image_size("gpt-image-1", "1024x1536") == "1024x1536"


def test_build_prompt_includes_all_fields():
    text = svc.build_prompt("sun", "oil", "calm", "blue")
    assert "sun" in text and "oil" in text and "calm" in text and "blue" in text
    assert "copyright" in text.lower() or "Avoid" in text


def test_system_prompt_nonempty():
    assert len(svc.SYSTEM_PROMPT) > 50
