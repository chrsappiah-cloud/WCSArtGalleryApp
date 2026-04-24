from datetime import datetime

from pydantic import BaseModel, ConfigDict, HttpUrl


class ArtworkRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    artist_name: str
    description: str | None
    medium: str | None
    year: str | None
    image_url: str
    thumbnail_url: str | None
    source_type: str
    external_source: str | None
    prompt_used: str | None
    created_at: datetime


class ArtworkCreate(BaseModel):
    title: str
    artist_name: str = "World Class Scholars"
    description: str | None = None
    medium: str | None = None
    year: str | None = None
    image_url: str
    thumbnail_url: str | None = None
    source_type: str = "upload"
    external_source: str | None = None
    prompt_used: str | None = None


class PromptRequest(BaseModel):
    concept: str
    style: str = "editorial fine art photography"
    mood: str = "museum-grade, luminous, contemporary"
    palette: str = "muted neutrals with controlled accents"
    aspect_ratio: str = "1024x1024"


class PromptResponse(BaseModel):
    system_prompt: str
    final_prompt: str


class ExternalImportRequest(BaseModel):
    endpoint: HttpUrl
    results_path: str | None = None
    title_field: str = "title"
    image_field: str = "image_url"
    artist_field: str = "artist_name"
    limit: int = 12
