from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.core.config import settings
from app.db.database import init_db
from app.routers import ai, artworks, health, uploads

app = FastAPI(title=settings.app_name)

_media = Path(settings.media_root)
_media.mkdir(parents=True, exist_ok=True)
app.mount("/media", StaticFiles(directory=str(_media)), name="media")

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(artworks.router, prefix="/api")
app.include_router(uploads.router, prefix="/api")
app.include_router(ai.router, prefix="/api")


@app.on_event("startup")
async def startup() -> None:
    await init_db()
