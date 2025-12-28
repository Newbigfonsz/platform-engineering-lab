from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import RedirectResponse
from pydantic import BaseModel, HttpUrl
import asyncpg
import hashlib
import os

app = FastAPI(title="URL Shortener", description="Alphonzo's URL Shortener API")

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://shortener:shortener123@postgres:5432/shortener")

class URLCreate(BaseModel):
    url: HttpUrl

class URLResponse(BaseModel):
    short_code: str
    short_url: str
    original_url: str
    clicks: int

async def get_db():
    return await asyncpg.connect(DATABASE_URL)

@app.on_event("startup")
async def startup():
    conn = await get_db()
    await conn.execute('''
        CREATE TABLE IF NOT EXISTS urls (
            id SERIAL PRIMARY KEY,
            short_code VARCHAR(10) UNIQUE NOT NULL,
            original_url TEXT NOT NULL,
            clicks INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    await conn.close()

@app.get("/")
async def root():
    return {"message": "URL Shortener API", "docs": "/docs"}

@app.post("/shorten", response_model=URLResponse)
async def shorten_url(url_data: URLCreate, request: Request):
    conn = await get_db()
    
    # Generate short code from URL hash
    short_code = hashlib.md5(str(url_data.url).encode()).hexdigest()[:6]
    
    # Check if exists
    existing = await conn.fetchrow("SELECT * FROM urls WHERE short_code = $1", short_code)
    if existing:
        await conn.close()
        base_url = str(request.base_url)
        return URLResponse(
            short_code=short_code,
            short_url=f"{base_url}r/{short_code}",
            original_url=str(url_data.url),
            clicks=existing['clicks']
        )
    
    # Insert new URL
    await conn.execute(
        "INSERT INTO urls (short_code, original_url) VALUES ($1, $2)",
        short_code, str(url_data.url)
    )
    await conn.close()
    
    base_url = str(request.base_url)
    return URLResponse(
        short_code=short_code,
        short_url=f"{base_url}r/{short_code}",
        original_url=str(url_data.url),
        clicks=0
    )

@app.get("/r/{short_code}")
async def redirect_url(short_code: str):
    conn = await get_db()
    
    url = await conn.fetchrow("SELECT * FROM urls WHERE short_code = $1", short_code)
    if not url:
        await conn.close()
        raise HTTPException(status_code=404, detail="URL not found")
    
    # Increment clicks
    await conn.execute("UPDATE urls SET clicks = clicks + 1 WHERE short_code = $1", short_code)
    await conn.close()
    
    return RedirectResponse(url=url['original_url'])

@app.get("/stats/{short_code}", response_model=URLResponse)
async def get_stats(short_code: str, request: Request):
    conn = await get_db()
    
    url = await conn.fetchrow("SELECT * FROM urls WHERE short_code = $1", short_code)
    if not url:
        await conn.close()
        raise HTTPException(status_code=404, detail="URL not found")
    
    await conn.close()
    base_url = str(request.base_url)
    return URLResponse(
        short_code=short_code,
        short_url=f"{base_url}r/{short_code}",
        original_url=url['original_url'],
        clicks=url['clicks']
    )

@app.get("/all")
async def list_all():
    conn = await get_db()
    urls = await conn.fetch("SELECT * FROM urls ORDER BY created_at DESC LIMIT 50")
    await conn.close()
    return [dict(u) for u in urls]
