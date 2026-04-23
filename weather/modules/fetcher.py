"""OpenWeatherMap API client helpers for current weather and forecast data."""

from __future__ import annotations

from datetime import datetime

import requests

from config import BASE_URL, OPENWEATHER_API_KEY, REQUEST_TIMEOUT, UNITS


class WeatherAPIError(Exception):
    """Raised when the weather API returns a known, user-friendly error."""


def _ensure_api_key() -> None:
    """Validate that an API key is available before making a request."""
    if not OPENWEATHER_API_KEY:
        raise WeatherAPIError(
            "Missing OpenWeatherMap API key. Add OPENWEATHER_API_KEY to your .env file."
        )


def _request(endpoint: str, city: str) -> dict:
    """Send a GET request to the OpenWeatherMap API and return the JSON body."""
    _ensure_api_key()

    try:
        response = requests.get(
            f"{BASE_URL}/{endpoint}",
            params={
                "q": city,
                "appid": OPENWEATHER_API_KEY,
                "units": UNITS,
            },
            timeout=REQUEST_TIMEOUT,
        )
    except requests.Timeout as exc:
        raise WeatherAPIError(
            "The weather service timed out. Please try again in a moment."
        ) from exc
    except requests.RequestException as exc:
        raise WeatherAPIError(
            "Unable to reach the weather service. Check your network connection and try again."
        ) from exc

    if response.status_code == 401:
        raise WeatherAPIError(
            "OpenWeatherMap rejected the API key. Verify OPENWEATHER_API_KEY in your .env file."
        )
    if response.status_code == 404:
        raise WeatherAPIError(
            f'City "{city}" was not found. Check the spelling and try again.'
        )
    if response.status_code >= 400:
        try:
            payload = response.json()
            message = payload.get("message", "Unexpected API error.")
        except ValueError:
            message = "Unexpected API error."
        raise WeatherAPIError(f"Weather API error: {message}")

    return response.json()


def _parse_current_weather(payload: dict) -> dict:
    """Normalize the current weather response into a simple dictionary."""
    weather_item = payload.get("weather", [{}])[0]
    main = payload.get("main", {})
    wind = payload.get("wind", {})
    timestamp = datetime.utcfromtimestamp(payload.get("dt", 0)).isoformat()

    return {
        "city": payload.get("name", ""),
        "temperature": float(main.get("temp", 0.0)),
        "feels_like": float(main.get("feels_like", 0.0)),
        "humidity": int(main.get("humidity", 0)),
        "wind_speed": float(wind.get("speed", 0.0)),
        "description": weather_item.get("description", "Unknown").title(),
        "icon_hint": weather_item.get("main", "").lower(),
        "timestamp": timestamp,
    }


def fetch_current_weather(city: str) -> dict:
    """Fetch and parse current weather for a single city."""
    payload = _request("weather", city)
    return _parse_current_weather(payload)


def fetch_forecast(city: str) -> list[dict]:
    """Fetch and parse the 5-day / 3-hour forecast for a city."""
    payload = _request("forecast", city)
    city_name = payload.get("city", {}).get("name", city)
    records: list[dict] = []

    for item in payload.get("list", []):
        weather_item = item.get("weather", [{}])[0]
        main = item.get("main", {})
        wind = item.get("wind", {})
        timestamp = datetime.utcfromtimestamp(item.get("dt", 0)).isoformat()
        records.append(
            {
                "city": city_name,
                "temperature": float(main.get("temp", 0.0)),
                "feels_like": float(main.get("feels_like", 0.0)),
                "humidity": int(main.get("humidity", 0)),
                "wind_speed": float(wind.get("speed", 0.0)),
                "description": weather_item.get("description", "Unknown").title(),
                "icon_hint": weather_item.get("main", "").lower(),
                "timestamp": timestamp,
            }
        )

    return records
