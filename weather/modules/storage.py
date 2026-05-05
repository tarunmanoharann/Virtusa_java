"""SQLite storage helpers for persisted weather history."""

from __future__ import annotations

import sqlite3
from datetime import datetime, timedelta

from config import DB_PATH


def get_connection() -> sqlite3.Connection:
    """Return a SQLite connection with row access by column name."""
    connection = sqlite3.connect(DB_PATH)
    connection.row_factory = sqlite3.Row
    return connection


def init_db() -> None:
    """Create the weather_records table if it does not exist yet."""
    with get_connection() as connection:
        connection.execute(
            """
            CREATE TABLE IF NOT EXISTS weather_records (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                city TEXT NOT NULL,
                temperature REAL NOT NULL,
                humidity INTEGER NOT NULL,
                wind_speed REAL NOT NULL,
                description TEXT NOT NULL,
                timestamp TEXT NOT NULL
            )
            """
        )
        connection.commit()


def save_record(data_dict: dict) -> None:
    """Insert a single normalized weather record into the database."""
    init_db()
    with get_connection() as connection:
        connection.execute(
            """
            INSERT INTO weather_records (
                city, temperature, humidity, wind_speed, description, timestamp
            )
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (
                data_dict.get("city", ""),
                data_dict.get("temperature", 0.0),
                data_dict.get("humidity", 0),
                data_dict.get("wind_speed", 0.0),
                data_dict.get("description", "Unknown"),
                data_dict.get("timestamp", datetime.utcnow().isoformat()),
            ),
        )
        connection.commit()


def get_history(city: str, days: int = 7) -> list[dict]:
    """Return weather records for a city within the last N days."""
    init_db()
    cutoff = (datetime.utcnow() - timedelta(days=days)).isoformat()

    with get_connection() as connection:
        rows = connection.execute(
            """
            SELECT id, city, temperature, humidity, wind_speed, description, timestamp
            FROM weather_records
            WHERE LOWER(city) = LOWER(?)
              AND timestamp >= ?
            ORDER BY timestamp ASC
            """,
            (city, cutoff),
        ).fetchall()

    return [dict(row) for row in rows]


def get_paginated_history(city: str, page: int = 1, per_page: int = 10) -> tuple[list[dict], int]:
    """Return paginated historical records and the total number of rows."""
    init_db()
    offset = max(page - 1, 0) * per_page

    with get_connection() as connection:
        total = connection.execute(
            """
            SELECT COUNT(*) AS total
            FROM weather_records
            WHERE LOWER(city) = LOWER(?)
            """,
            (city,),
        ).fetchone()["total"]

        rows = connection.execute(
            """
            SELECT id, city, temperature, humidity, wind_speed, description, timestamp
            FROM weather_records
            WHERE LOWER(city) = LOWER(?)
            ORDER BY timestamp DESC
            LIMIT ? OFFSET ?
            """,
            (city, per_page, offset),
        ).fetchall()

    return [dict(row) for row in rows], total


def get_all_cities() -> list[str]:
    """List unique stored cities, sorted alphabetically."""
    init_db()
    with get_connection() as connection:
        rows = connection.execute(
            """
            SELECT DISTINCT city
            FROM weather_records
            WHERE city != ''
            ORDER BY city ASC
            """
        ).fetchall()

    return [row["city"] for row in rows]
