"""HTTP coverage for artwork + upload routes not covered elsewhere."""

import io


def test_get_artwork_not_found_returns_404(client):
    response = client.get("/api/artworks/999999999")
    assert response.status_code == 404
    assert "not found" in response.json().get("detail", "").lower()


def test_create_artwork_then_get_by_id(client):
    payload = {
        "title": "CI Route Test",
        "artist_name": "pytest",
        "description": "temp",
        "medium": "ink",
        "year": "2026",
        "image_url": "https://example.com/ci.png",
        "thumbnail_url": "https://example.com/ci-thumb.png",
        "source_type": "upload",
        "external_source": None,
        "prompt_used": None,
    }
    created = client.post("/api/artworks", json=payload)
    assert created.status_code == 200
    body = created.json()
    assert body["title"] == "CI Route Test"
    artwork_id = body["id"]

    fetched = client.get(f"/api/artworks/{artwork_id}")
    assert fetched.status_code == 200
    got = fetched.json()
    assert got["id"] == artwork_id
    assert got["title"] == "CI Route Test"


def test_upload_artwork_rejects_non_image(client):
    files = {"file": ("notes.txt", io.BytesIO(b"plain text"), "text/plain")}
    data = {"title": "Bad", "artist_name": "pytest", "description": ""}
    response = client.post("/api/upload-artwork", files=files, data=data)
    assert response.status_code == 400
    assert "image" in response.json().get("detail", "").lower()


def test_options_preflight_post_upload(client):
    response = client.options(
        "/api/upload-artwork",
        headers={
            "Origin": "http://localhost:8080",
            "Access-Control-Request-Method": "POST",
        },
    )
    assert response.status_code == 200
    assert "access-control-allow-methods" in response.headers


def test_options_preflight_ai_prompt(client):
    response = client.options(
        "/api/ai/prompt",
        headers={
            "Origin": "http://127.0.0.1:8000",
            "Access-Control-Request-Method": "POST",
        },
    )
    assert response.status_code == 200
