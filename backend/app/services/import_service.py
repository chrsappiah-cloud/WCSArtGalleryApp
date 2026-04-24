from typing import Any

import httpx


async def fetch_json(endpoint: str) -> Any:
    async with httpx.AsyncClient(timeout=60) as client:
        response = await client.get(endpoint)
        response.raise_for_status()
        return response.json()
