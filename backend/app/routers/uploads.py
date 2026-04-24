from pathlib import Path

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.db.database import get_session
from app.models.artwork import Artwork as ArtworkORM
from app.schemas.artwork import ExternalImportRequest
from app.services.import_service import fetch_json
from app.services.met_open_access import fetch_met_objects_sample
from app.services.storage import save_upload

router = APIRouter(tags=["uploads"])


def _media_relative(abs_path: str) -> str:
    rel = Path(abs_path).relative_to(Path(settings.media_root))
    return "/" + rel.as_posix()


@router.post("/upload-artwork")
async def upload_artwork(
    title: str = Form(...),
    artist_name: str = Form("World Class Scholars"),
    description: str = Form(""),
    file: UploadFile = File(...),
    session: AsyncSession = Depends(get_session),
) -> dict:
    if not (file.content_type or "").startswith("image/"):
        raise HTTPException(status_code=400, detail="Only image uploads are supported")
    stored = await save_upload(file)
    rel = _media_relative(stored)
    row = ArtworkORM(
        title=title,
        artist_name=artist_name,
        description=description or None,
        image_url=rel,
        thumbnail_url=rel,
        source_type="upload",
    )
    session.add(row)
    await session.commit()
    await session.refresh(row)
    return {"id": row.id, "image_url": rel}


@router.post("/import-external")
async def import_external(
    payload: ExternalImportRequest,
    session: AsyncSession = Depends(get_session),
) -> dict:
    data = await fetch_json(str(payload.endpoint))
    if isinstance(data, list):
        items = data
    elif isinstance(data, dict):
        key = payload.results_path or "results"
        items = data.get(key) or data.get("data") or []
    else:
        items = []
    created = 0
    for item in items[: payload.limit]:
        image = item.get(payload.image_field)
        if not image:
            continue
        desc_raw = item.get("description")
        description = (
            str(desc_raw)[:4096] if desc_raw else "Imported from external API"
        )
        row = ArtworkORM(
            title=str(item.get(payload.title_field, "Untitled"))[:512],
            artist_name=str(item.get(payload.artist_field, "Unknown"))[:512],
            description=description,
            image_url=str(image)[:4096],
            thumbnail_url=str(item.get("thumbnail_url") or image)[:4096],
            source_type="external_api",
            external_source=str(payload.endpoint)[:1024],
        )
        session.add(row)
        created += 1
    await session.commit()
    return {"imported": created}


@router.post("/import/open-access-met-sample")
async def import_met_sample(
    session: AsyncSession = Depends(get_session),
    limit: int = 6,
) -> dict:
    rows = await fetch_met_objects_sample(limit=limit)
    for row in rows:
        session.add(
            ArtworkORM(
                title=row["title"][:512],
                artist_name=row["artist_name"][:512],
                description=(row.get("description") or "")[:4096] or None,
                medium=(row.get("medium") or "")[:255] or None,
                year=(row.get("year") or "")[:64] or None,
                image_url=row["image_url"][:4096],
                thumbnail_url=(row.get("thumbnail_url") or row["image_url"])[:4096],
                source_type="external_api",
                external_source=(row.get("external_source") or "")[:1024],
            )
        )
    await session.commit()
    return {"imported": len(rows)}
