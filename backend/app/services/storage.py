import uuid
from pathlib import Path

import aiofiles
from fastapi import UploadFile

from app.core.config import settings


def media_root() -> Path:
    root = Path(settings.media_root)
    root.mkdir(parents=True, exist_ok=True)
    return root


async def save_upload(file: UploadFile) -> str:
    ext = Path(file.filename or "image.jpg").suffix or ".jpg"
    name = f"{uuid.uuid4().hex}{ext}"
    target = media_root() / "uploads" / name
    target.parent.mkdir(parents=True, exist_ok=True)
    async with aiofiles.open(target, "wb") as out:
        while chunk := await file.read(1024 * 1024):
            await out.write(chunk)
    return str(target.resolve())
