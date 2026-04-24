from pathlib import Path

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_name: str = "World Class Scholars Art Gallery API"
    app_env: str = "development"
    app_host: str = "0.0.0.0"
    app_port: int = 8000

    database_url: str = "sqlite+aiosqlite:///./wcs_gallery.db"
    media_root: Path = Path(__file__).resolve().parents[2] / "media"

    openai_api_key: str | None = None
    openai_image_model: str = "gpt-image-1.5"
    # If set (e.g. https://api.example.com), `/media/...` URLs use this origin instead of request.base_url.
    public_base_url: str | None = None

    allowed_origins: list[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://127.0.0.1:8000",
        "http://localhost:8000",
    ]

    @field_validator("openai_api_key", mode="before")
    @classmethod
    def strip_openai_key(cls, value: object) -> str | None:
        if value is None:
            return None
        s = str(value).strip()
        return s or None

    @field_validator("public_base_url", mode="before")
    @classmethod
    def strip_public_base_url(cls, value: object) -> str | None:
        if value is None:
            return None
        s = str(value).strip().rstrip("/")
        return s or None

    @field_validator("allowed_origins", mode="before")
    @classmethod
    def split_origins(cls, value: object) -> list[str]:
        if isinstance(value, str):
            return [p.strip() for p in value.split(",") if p.strip()]
        if isinstance(value, list):
            return [str(p).strip() for p in value if str(p).strip()]
        return []


settings = Settings()
