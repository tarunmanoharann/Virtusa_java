"""Analytical helpers for weather trends, anomalies, and summaries."""

from __future__ import annotations

from collections import Counter

import pandas as pd


def compute_stats(records: list[dict]) -> dict:
    """Compute descriptive statistics and a simple temperature trend label."""
    if not records:
        return {
            "avg_temp": None,
            "max_temp": None,
            "min_temp": None,
            "avg_humidity": None,
            "temp_trend": "stable",
        }

    frame = pd.DataFrame(records)
    frame["timestamp"] = pd.to_datetime(frame["timestamp"])
    frame = frame.sort_values("timestamp")

    avg_temp = round(frame["temperature"].mean(), 2)
    max_temp = round(frame["temperature"].max(), 2)
    min_temp = round(frame["temperature"].min(), 2)
    avg_humidity = round(frame["humidity"].mean(), 2)

    trend_slope = 0.0
    if len(frame) > 1:
        trend_slope = frame["temperature"].iloc[-1] - frame["temperature"].iloc[0]

    if trend_slope > 1:
        trend = "rising"
    elif trend_slope < -1:
        trend = "falling"
    else:
        trend = "stable"

    return {
        "avg_temp": avg_temp,
        "max_temp": max_temp,
        "min_temp": min_temp,
        "avg_humidity": avg_humidity,
        "temp_trend": trend,
    }


def detect_anomalies(records: list[dict]) -> list[dict]:
    """Return records whose temperatures are more than two standard deviations away."""
    if len(records) < 3:
        return []

    frame = pd.DataFrame(records)
    std_dev = frame["temperature"].std()
    if pd.isna(std_dev) or std_dev == 0:
        return []

    mean_temp = frame["temperature"].mean()
    anomaly_mask = (frame["temperature"] - mean_temp).abs() > (2 * std_dev)
    anomalies = frame[anomaly_mask].copy()

    return anomalies.to_dict(orient="records")


def summarize_conditions(records: list[dict]) -> str:
    """Return the most frequently observed weather description."""
    if not records:
        return "No conditions recorded yet"

    descriptions = [record.get("description", "Unknown") for record in records]
    most_common, _ = Counter(descriptions).most_common(1)[0]
    return most_common
