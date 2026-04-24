from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.database import get_session
from app.models.artwork import Artwork as ArtworkORM
from app.schemas.artwork import ArtworkCreate, ArtworkRead

router = APIRouter(tags=["artworks"])


def _absolutize_media(request: Request, url: str) -> str:
    if url.startswith("http://") or url.startswith("https://"):
        return url
    if url.startswith("/"):
        return f"{str(request.base_url).rstrip('/')}{url}"
    return url


@router.get("/artworks", response_model=list[ArtworkRead])
async def list_artworks(
    request: Request, session: AsyncSession = Depends(get_session)
) -> list[ArtworkRead]:
    result = await session.execute(select(ArtworkORM).order_by(ArtworkORM.id.desc()))
    rows = list(result.scalars().all())
    base = str(request.base_url).rstrip("/")
    out: list[ArtworkRead] = []
    for row in rows:
        ar = ArtworkRead.model_validate(row)
        out.append(
            ar.model_copy(
                update={
                    "image_url": _absolutize_media(request, ar.image_url),
                    "thumbnail_url": _absolutize_media(request, ar.thumbnail_url)
                    if ar.thumbnail_url
                    else None,
                }
            )
        )
    return out


@router.get("/artworks/{artwork_id}", response_model=ArtworkRead)
async def get_artwork(
    artwork_id: int,
    request: Request,
    session: AsyncSession = Depends(get_session),
) -> ArtworkRead:
    row = await session.get(ArtworkORM, artwork_id)
    if not row:
        raise HTTPException(status_code=404, detail="Artwork not found")
    ar = ArtworkRead.model_validate(row)
    return ar.model_copy(
        update={
            "image_url": _absolutize_media(request, ar.image_url),
            "thumbnail_url": _absolutize_media(request, ar.thumbnail_url)
            if ar.thumbnail_url
            else None,
        }
    )


@router.post("/artworks", response_model=ArtworkRead)
async def create_artwork(
    body: ArtworkCreate,
    request: Request,
    session: AsyncSession = Depends(get_session),
) -> ArtworkRead:
    row = ArtworkORM(**body.model_dump())
    session.add(row)
    await session.commit()
    await session.refresh(row)
    ar = ArtworkRead.model_validate(row)
    return ar.model_copy(
        update={
            "image_url": _absolutize_media(request, ar.image_url),
            "thumbnail_url": _absolutize_media(request, ar.thumbnail_url)
            if ar.thumbnail_url
            else None,
        }
    )
