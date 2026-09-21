# NYC Taxi Weather dbt project

This scaffold organizes transformations of the raw NYC taxi and weather data in ClickHouse. No SQL models have been added yet.

- `models/staging`: views that standardize raw source fields and types.
- `models/intermediate`: views that prepare reusable joins and transformations.
- `models/marts`: tables containing final datasets for analysis and reporting.

## Local setup

Run these commands from the repository root with `dbt-clickhouse` available in the uv environment. Create a local profile copy only if one does not already exist:

```sh
cp -n dbt/profiles.yml.example dbt/profiles.yml
```

Set `CLICKHOUSE_DB`, `CLICKHOUSE_USER`, and `CLICKHOUSE_PASSWORD` in your shell environment before running dbt. The profile's `schema` selects the ClickHouse database. dbt does not automatically load the repository's `.env` file.

`profiles.yml.example` must never contain real secrets; keep its environment-variable references. Keep credentials out of committed files and retain those references in your local profile too. The commands below use the local profile explicitly and do not require `~/.dbt/profiles.yml`.

```sh
uv run dbt debug --project-dir dbt --profiles-dir dbt
uv run dbt parse --project-dir dbt --profiles-dir dbt
```

After SQL models and tests have been added, build them with:

```sh
uv run dbt build --project-dir dbt --profiles-dir dbt
```
