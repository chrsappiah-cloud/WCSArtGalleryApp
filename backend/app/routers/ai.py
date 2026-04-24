from pathlib import Path

from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.db.database import get_session
from app.models.artwork import Artwork as ArtworkORM
from app.schemas.artwork import PromptRequest, PromptResponse
from app.services import openai_service as svc

router = APIRouter(tags=["ai"])


@router.post("/ai/prompt", response_model=PromptResponse)
async def build_ai_prompt(payload: PromptRequest) -> PromptResponse:
    final = svc.build_prompt(
        payload.concept, payload.style, payload.mood, payload.palette
    )
    return PromptResponse(system_prompt=svc.SYSTEM_PROMPT, final_prompt=final)


@router.post("/ai/generate")
async def generate_ai_image(
    request: Request,
    payload: PromptRequest,
    session: AsyncSession = Depends(get_session),
) -> dict:
    final = svc.build_prompt(
        payload.concept, payload.style, payload.mood, payload.palette
    )
    try:
        local_path, remote = svc.generate_image(final, payload.aspect_ratio)
    except RuntimeError as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc

    if remote:
        image_ref = remote
    else:
        rel = "/" + Path(local_path).relative_to(Path(settings.media_root)).as_posix()
        base = str(request.base_url).rstrip("/")
        image_ref = f"{base}{rel}"

    row = ArtworkORM(
        title=payload.concept[:120],
        artist_name="AI Studio",
        description="AI-generated artwork for World Class Scholars",
        medium="Digital image",
        year="2026",
        image_url=image_ref[:4096],
        thumbnail_url=image_ref[:4096],
        source_type="ai_generated",
        prompt_used=final[:4096],
    )
    session.add(row)
    await session.commit()
    await session.refresh(row)
    return {"id": row.id, "image_url": image_ref, "prompt_used": row.prompt_used}
