"""Sample ingestion from The Met Collection API (open access, HTTPS)."""

from __future__ import annotations

import httpx

MET_SEARCH = "https://collectionapi.metmuseum.org/public/collection/v1/search"
MET_OBJECT = "https://collectionapi.metmuseum.org/public/collection/v1/objects"


async def fetch_met_objects_sample(*, query: str = "african textiles", limit: int = 6) -> list[dict]:
    async with httpx.AsyncClient(timeout=90) as client:
        search = await client.get(
            MET_SEARCH,
            params={"hasImages": True, "q": query},
        )
        search.raise_for_status()
        object_ids = search.json().get("objectIDs") or []
        rows: list[dict] = []
        for oid in object_ids[:limit]:
            obj = await client.get(f"{MET_OBJECT}/{oid}")
            obj.raise_for_status()
            data = obj.json()
            image = data.get("primaryImage") or data.get("primaryImageSmall")
            if not image:
                continue
            rows.append(
                {
                    "title": data.get("title") or "Untitled",
                    "artist_name": data.get("artistDisplayName") or "The Met Open Access",
                    "description": (data.get("objectDate") or "")
                    + (" — " + data.get("culture", "") if data.get("culture") else ""),
                    "medium": data.get("medium"),
                    "year": (data.get("objectDate") or "")[:64] or None,
                    "image_url": image,
                    "thumbnail_url": data.get("primaryImageSmall") or image,
                    "source_type": "external_api",
                    "external_source": f"{MET_OBJECT}/{oid}",
                    "prompt_used": None,
                }
            )
        return rows
