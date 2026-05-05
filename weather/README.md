# Weather Data Analyzer & Forecast Dashboard

A Flask-based weather dashboard that fetches current conditions from OpenWeatherMap, stores historical readings in SQLite, analyzes trends, and forecasts short-term temperatures with linear regression.

## Features

- Search any city and store current weather history locally
- Review 7-day temperature and humidity trends on a dark-themed dashboard
- Analyze averages, extremes, anomalies, and common conditions
- Generate a 24-hour forecast based on stored historical records
- Browse a sortable historical data table with pagination
- Power charts dynamically from the `/api/chart-data` JSON endpoint

## Getting an OpenWeatherMap API Key

1. Create a free account at [OpenWeatherMap](https://openweathermap.org/).
2. Open the API keys page in your account dashboard.
3. Generate or copy an API key.
4. Add it to your local `.env` file as `OPENWEATHER_API_KEY=your_key_here`.

## Setup

1. Clone the repository.
2. Move into the `weather/` project folder.
3. Create a `.env` file from the example:

```bash
cp .env.example .env
```

4. Add your OpenWeatherMap API key to `.env`.
5. Install dependencies:

```bash
pip install -r requirements.txt
```

6. Run the app:

```bash
python app.py
```

7. Open `http://127.0.0.1:5000/` in your browser.

## Usage

- Dashboard (`/`): View the latest city weather, summary cards, trend charts, and analysis insights.
- Search (`/search?city=CityName`): Fetch and save fresh current weather for a city, then return to the dashboard.
- History (`/history?city=CityName`): Browse stored records with pagination and sortable columns.
- Forecast (`/forecast?city=CityName`): Train a regression model on stored data and view a 24-hour prediction chart.
- Chart API (`/api/chart-data?city=CityName`): Returns JSON labels, temperature values, and humidity values for Chart.js.

## Notes

- The SQLite database is auto-created at `data/weather.db` on first use.
- The dashboard handles empty datasets gracefully, so you can start the app before collecting any records.
- No API keys are hardcoded in the source code.

## Example Screenshots

- Dashboard screenshot: _placeholder_
- History screenshot: _placeholder_
- Forecast screenshot: _placeholder_
