"""Application configuration for the Weather Data Analyzer dashboard."""

from __future__ import annotations

import os
from pathlib import Path

from dotenv import load_dotenv


BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "data"
DB_PATH = DATA_DIR / "weather.db"

load_dotenv(BASE_DIR / ".env")

OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY", "").strip()
SECRET_KEY = os.getenv("FLASK_SECRET_KEY", "dev-secret-change-me")

DEFAULT_CITY = "Chennai"
BASE_URL = "https://api.openweathermap.org/data/2.5"
UNITS = "metric"
REQUEST_TIMEOUT = 10
RECORDS_PER_PAGE = 10

# Ensure the data directory exists before SQLite attempts to create the file.
DATA_DIR.mkdir(parents=True, exist_ok=True)
