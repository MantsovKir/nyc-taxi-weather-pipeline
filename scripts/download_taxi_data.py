from pathlib import Path
from urllib.request import urlretrieve


BASE_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data"
OUTPUT_DIR = Path("data/raw/taxi")

PERIODS = {
    2025: range(1, 13),
    2026: range(1, 6),
}


def download_taxi_file(year: int, month: int) -> None:
    filename = f"yellow_tripdata_{year}-{month:02d}.parquet"
    url = f"{BASE_URL}/{filename}"
    output_path = OUTPUT_DIR / filename

    if output_path.exists():
        print(f"SKIP: {filename} already exists")
        return

    print(f"DOWNLOAD: {filename}")
    urlretrieve(url, output_path)
    print(f"DONE: {filename}")


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for year, months in PERIODS.items():
        for month in months:
            download_taxi_file(year, month)

    print("All available taxi files downloaded.")


if __name__ == "__main__":
    main()