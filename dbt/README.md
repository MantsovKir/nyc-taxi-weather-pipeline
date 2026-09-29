# NYC Taxi & Weather dbt models

This dbt project transforms raw NYC Yellow Taxi records and Open-Meteo hourly weather loaded by Sling into two ClickHouse marts used by the Power BI report. See the [root README](../README.md) for the data sources, architecture, results, and full setup.

## Model layers

| Layer | Models | Purpose |
|---|---|---|
| Staging | `stg_taxi_trips`, `stg_weather_hourly` | Standardize taxi fields and expand monthly weather JSON into hourly observations. |
| Intermediate | `int_taxi_trips_clean`, `int_taxi_hourly` | Keep the analysis period, flag trip quality, and aggregate citywide trips by pickup hour. |
| Marts | `mart_taxi_weather_hourly`, `mart_taxi_routes_hourly` | Supply hourly citywide weather metrics and hourly origin-destination route metrics. |

Staging and intermediate models are views. Both marts are ClickHouse `MergeTree` tables. The `taxi_zone_lookup` seed supplies pickup and dropoff zone names to the routes mart.

The citywide weather mart has one row per weather hour. The routes mart has one row per pickup hour, pickup zone, dropoff zone, and validity flag. Sum `trip_count` to count trips from route groups. `total_valid_amount` sums amounts for valid trips in each group.

## Local commands

From the repository root, copy the example profile and load the local ClickHouse credentials from `.env` into the shell. The profile reads `CLICKHOUSE_DB`, `CLICKHOUSE_USER`, and `CLICKHOUSE_PASSWORD` from environment variables; dbt does not automatically read `.env`.

```bash
cp -n dbt/profiles.yml.example dbt/profiles.yml
set -a
. ./.env
set +a
uv sync --locked
uv run dbt debug --project-dir dbt --profiles-dir dbt
uv run dbt seed --project-dir dbt --profiles-dir dbt --select taxi_zone_lookup
uv run dbt build --project-dir dbt --profiles-dir dbt \
  --select +mart_taxi_weather_hourly +mart_taxi_routes_hourly
```

The build runs model and data tests. Tests include required and accepted values, uniqueness of weather hours and route keys, and consistency checks for hourly taxi metrics. Raw data must be loaded first using the steps in the root README. Keep the local `dbt/profiles.yml` and `.env` files out of Git.
