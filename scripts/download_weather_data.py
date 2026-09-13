import json
from calendar import monthrange
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import urlopen


BASE_URL = "https://archive-api.open-meteo.com/v1/archive"
OUTPUT_DIR = Path("data/raw/weather")

LATITUDE = 40.7128
LONGITUDE = -74.0060

PERIODS = {
    2025: range(1, 13),
    2026: range(1, 6),
}

HOURLY_VARIABLES = [
    "temperature_2m",
    "apparent_temperature",
    "relative_humidity_2m",
    "precipitation",
    "rain",
    "snowfall",
    "weather_code",
    "wind_speed_10m",
    "wind_gusts_10m",
]


def download_weather_file(year: int, month: int) -> None:
    last_day = monthrange(year, month)[1]

    start_date = f"{year}-{month:02d}-01"
    end_date = f"{year}-{month:02d}-{last_day:02d}"

    filename = f"weather_{year}-{month:02d}.json"
    output_path = OUTPUT_DIR / filename
    temporary_path = OUTPUT_DIR / f"{filename}.part"

    if output_path.exists():
        print(f"SKIP: {filename} already exists")
        return

    parameters = {
        "latitude": LATITUDE,
        "longitude": LONGITUDE,
        "start_date": start_date,
        "end_date": end_date,
        "hourly": ",".join(HOURLY_VARIABLES),
        "timezone": "America/New_York",
        "temperature_unit": "celsius",
        "wind_speed_unit": "kmh",
        "precipitation_unit": "mm",
    }

    url = f"{BASE_URL}?{urlencode(parameters)}"

    print(f"DOWNLOAD: {filename}")

    with urlopen(url) as response:
        weather_data = json.load(response)

    if weather_data.get("error"):
        raise RuntimeError(weather_data.get("reason", "Unknown API error"))

    with temporary_path.open("w", encoding="utf-8") as file:
        json.dump(weather_data, file, ensure_ascii=False, indent=2)

    temporary_path.replace(output_path)

    print(f"DONE: {filename}")


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for year, months in PERIODS.items():
        for month in months:
            download_weather_file(year, month)

    print("All available weather files downloaded.")


if __name__ == "__main__":
    main()