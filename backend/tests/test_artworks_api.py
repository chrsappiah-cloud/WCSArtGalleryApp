def test_ai_prompt_returns_prompt_bundle(client):
    response = client.post(
        "/api/ai/prompt",
        json={
            "concept": "rivers at dawn",
            "style": "minimal",
            "mood": "calm",
            "palette": "blue",
            "aspect_ratio": "1024x1024",
        },
    )
    assert response.status_code == 200
    body = response.json()
    assert "final_prompt" in body and "system_prompt" in body
    assert "rivers at dawn" in body["final_prompt"]


def test_list_artworks_returns_json_array(client):
    response = client.get("/api/artworks")
    assert response.status_code == 200
    body = response.json()
    assert isinstance(body, list)


def test_ai_generate_requires_configured_openai_or_returns_503(client):
    response = client.post(
        "/api/ai/generate",
        json={
            "concept": "test",
            "style": "s",
            "mood": "m",
            "palette": "p",
            "aspect_ratio": "1024x1024",
        },
    )
    assert response.status_code in (503, 200)
    if response.status_code == 503:
        assert "OPENAI" in response.json().get("detail", "").upper()
