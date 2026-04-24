from datetime import datetime

from sqlalchemy import DateTime, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column

from app.db.database import Base


class Artwork(Base):
    __tablename__ = "artworks"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    title: Mapped[str] = mapped_column(String(512), default="")
    artist_name: Mapped[str] = mapped_column(String(512), default="")
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    medium: Mapped[str | None] = mapped_column(String(255), nullable=True)
    year: Mapped[str | None] = mapped_column(String(64), nullable=True)
    image_url: Mapped[str] = mapped_column(String(4096), default="")
    thumbnail_url: Mapped[str | None] = mapped_column(String(4096), nullable=True)
    source_type: Mapped[str] = mapped_column(String(64), default="upload")
    external_source: Mapped[str | None] = mapped_column(String(1024), nullable=True)
    prompt_used: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
    )
