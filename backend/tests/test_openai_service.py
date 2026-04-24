"""Pure prompt logic; image generation requires a real API key."""

from app.services import openai_service as svc


def test_build_prompt_includes_all_fields():
    text = svc.build_prompt("sun", "oil", "calm", "blue")
    assert "sun" in text and "oil" in text and "calm" in text and "blue" in text
    assert "copyright" in text.lower() or "Avoid" in text


def test_system_prompt_nonempty():
    assert len(svc.SYSTEM_PROMPT) > 50
