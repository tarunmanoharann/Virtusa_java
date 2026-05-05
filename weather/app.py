"""Flask entry point for the Weather Data Analyzer dashboard."""

from __future__ import annotations

import math
from datetime import datetime

from flask import Flask, flash, jsonify, redirect, render_template, request, session, url_for

from config import DEFAULT_CITY, RECORDS_PER_PAGE, SECRET_KEY
from modules.analyzer import compute_stats, detect_anomalies, summarize_conditions
from modules.fetcher import WeatherAPIError, fetch_current_weather
from modules.predictor import predict_temperature
from modules.storage import get_all_cities, get_history, get_paginated_history, init_db, save_record


app = Flask(__name__)
app.config["SECRET_KEY"] = SECRET_KEY


def _selected_city() -> str:
    """Resolve the active city from the query string, session, or defaults."""
    city = request.args.get("city", "").strip() or session.get("last_city") or DEFAULT_CITY
    return city.strip() or DEFAULT_CITY


def _format_datetime(value: str | None) -> str:
    """Format ISO timestamps for human-friendly display."""
    if not value:
        return "N/A"
    try:
        return datetime.fromisoformat(value).strftime("%Y-%m-%d %H:%M")
    except ValueError:
        return value


def _icon_class(description: str | None) -> str:
    """Map a description to a CSS weather icon class."""
    text = (description or "").lower()
    if "rain" in text or "drizzle" in text or "storm" in text:
        return "rainy"
    if "cloud" in text or "mist" in text or "fog" in text:
        return "cloudy"
    return "sunny"


def _build_chart_payload(records: list[dict], city: str) -> dict:
    """Transform records into chart-ready JSON arrays."""
    labels = [_format_datetime(record.get("timestamp")) for record in records]
    temperatures = [record.get("temperature") for record in records]
    humidities = [record.get("humidity") for record in records]
    return {
        "city": city,
        "labels": labels,
        "temperatures": temperatures,
        "humidities": humidities,
        "has_data": bool(records),
    }


def _prepared_history(records: list[dict]) -> list[dict]:
    """Add display timestamps while preserving the raw values."""
    prepared = []
    for record in records:
        prepared_record = dict(record)
        prepared_record["display_timestamp"] = _format_datetime(record.get("timestamp"))
        prepared.append(prepared_record)
    return prepared


@app.route("/")
def index():
    """Render the main dashboard view."""
    init_db()
    city = _selected_city()
    session["last_city"] = city

    current_weather = None
    error_message = None

    try:
        current_weather = fetch_current_weather(city)
    except WeatherAPIError as exc:
        error_message = str(exc)

    history_records = get_history(city, days=7)
    stats = compute_stats(history_records)
    anomalies = detect_anomalies(history_records)
    common_condition = summarize_conditions(history_records)
    chart_payload = _build_chart_payload(history_records, city)

    return render_template(
        "index.html",
        city=city,
        current_weather=current_weather,
        stats=stats,
        anomalies=_prepared_history(anomalies),
        common_condition=common_condition,
        chart_payload=chart_payload,
        available_cities=get_all_cities(),
        icon_class=_icon_class(
            (current_weather or {}).get("description") or common_condition
        ),
        updated_at=_format_datetime((current_weather or {}).get("timestamp")),
        error_message=error_message,
    )


@app.route("/search")
def search():
    """Fetch and persist the latest weather record for the requested city."""
    city = request.args.get("city", "").strip()
    if not city:
        flash("Enter a city name to search.", "warning")
        return redirect(url_for("index"))

    try:
        current_weather = fetch_current_weather(city)
        save_record(current_weather)
        session["last_city"] = current_weather.get("city", city)
        flash(f'Saved latest weather for {current_weather.get("city", city)}.', "success")
        return redirect(url_for("index", city=current_weather.get("city", city)))
    except WeatherAPIError as exc:
        flash(str(exc), "error")
        return redirect(url_for("index", city=city))


@app.route("/history")
def history():
    """Render paginated historical data for a selected city."""
    init_db()
    city = _selected_city()
    session["last_city"] = city

    page = max(request.args.get("page", 1, type=int), 1)
    records, total = get_paginated_history(city, page=page, per_page=RECORDS_PER_PAGE)
    total_pages = max(math.ceil(total / RECORDS_PER_PAGE), 1)

    return render_template(
        "history.html",
        city=city,
        records=_prepared_history(records),
        page=page,
        total_pages=total_pages,
        total_records=total,
        available_cities=get_all_cities(),
    )


@app.route("/forecast")
def forecast():
    """Render model-based forecast output for a selected city."""
    init_db()
    city = _selected_city()
    session["last_city"] = city

    historical_records = get_history(city, days=7)
    prediction = predict_temperature(historical_records, hours_ahead=24)
    prepared_history = _prepared_history(historical_records)

    forecast_labels = [_format_datetime(item[0]) for item in prediction["forecast_points"]]
    forecast_temps = [item[1] for item in prediction["forecast_points"]]
    history_labels = [record["display_timestamp"] for record in prepared_history]
    history_temps = [record["temperature"] for record in prepared_history]

    return render_template(
        "forecast.html",
        city=city,
        prediction=prediction,
        history_records=prepared_history,
        forecast_labels=forecast_labels,
        forecast_temps=forecast_temps,
        history_labels=history_labels,
        history_temps=history_temps,
        available_cities=get_all_cities(),
    )


@app.route("/api/chart-data")
def chart_data():
    """Return chart data arrays for the selected city."""
    city = _selected_city()
    records = get_history(city, days=7)
    return jsonify(_build_chart_payload(records, city))


if __name__ == "__main__":
    init_db()
    app.run(debug=True)
