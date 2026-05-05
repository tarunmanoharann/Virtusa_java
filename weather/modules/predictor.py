"""Prediction helpers that forecast short-term temperature movement."""

from __future__ import annotations

from datetime import timedelta

import pandas as pd
from sklearn.linear_model import LinearRegression


def predict_temperature(records: list[dict], hours_ahead: int = 24) -> dict:
    """Predict future temperatures using linear regression over timestamps."""
    if len(records) < 2:
        return {
            "predicted_temperature": None,
            "confidence_note": "Not enough historical data to generate a forecast yet.",
            "forecast_points": [],
        }

    frame = pd.DataFrame(records)
    frame["timestamp"] = pd.to_datetime(frame["timestamp"])
    frame = frame.sort_values("timestamp")

    origin = frame["timestamp"].min()
    x_values = (
        (frame["timestamp"] - origin).dt.total_seconds().div(3600).to_numpy().reshape(-1, 1)
    )
    y_values = frame["temperature"].to_numpy()

    model = LinearRegression()
    model.fit(x_values, y_values)

    last_timestamp = frame["timestamp"].max()
    future_offsets = list(range(3, hours_ahead + 1, 3))
    forecast_points: list[tuple[str, float]] = []

    for offset in future_offsets:
        future_timestamp = last_timestamp + timedelta(hours=offset)
        x_future = [[(future_timestamp - origin).total_seconds() / 3600]]
        predicted_value = float(model.predict(x_future)[0])
        forecast_points.append((future_timestamp.isoformat(), round(predicted_value, 2)))

    predicted_temperature = forecast_points[-1][1] if forecast_points else None
    confidence_note = (
        "Forecast is based on a simple linear regression trend and is best used as a directional estimate."
    )

    return {
        "predicted_temperature": predicted_temperature,
        "confidence_note": confidence_note,
        "forecast_points": forecast_points,
    }
