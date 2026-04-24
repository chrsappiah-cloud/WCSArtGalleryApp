"""CORS middleware (only cross-cutting 'middleware' in this stack)."""


def test_cors_allows_configured_origin_on_get(client):
    response = client.get(
        "/health",
        headers={"Origin": "http://localhost:3000"},
    )
    assert response.status_code == 200
    assert response.headers.get("access-control-allow-origin") in (
        "http://localhost:3000",
        "*",
    )


def test_options_preflight_artworks(client):
    response = client.options(
        "/api/artworks",
        headers={
            "Origin": "http://localhost:8080",
            "Access-Control-Request-Method": "GET",
        },
    )
    assert response.status_code == 200
    assert "access-control-allow-methods" in response.headers
