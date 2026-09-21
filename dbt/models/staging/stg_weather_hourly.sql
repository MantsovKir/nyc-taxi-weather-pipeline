with source as (
    select
        ifNull(data, '{}') as data,
        _sling_stream_url,
        _sling_loaded_at
    from {{ source('raw', 'raw_weather') }}
),

hourly_arrays as (
    select
        JSONExtractString(data, 'timezone') as timezone,
        JSONExtract(data, 'hourly', 'time', 'Array(String)') as hourly_time,
        JSONExtract(data, 'hourly', 'temperature_2m', 'Array(Nullable(Float64))') as temperature_2m,
        JSONExtract(data, 'hourly', 'apparent_temperature', 'Array(Nullable(Float64))') as apparent_temperature,
        JSONExtract(data, 'hourly', 'relative_humidity_2m', 'Array(Nullable(Int64))') as relative_humidity_2m,
        JSONExtract(data, 'hourly', 'precipitation', 'Array(Nullable(Float64))') as precipitation,
        JSONExtract(data, 'hourly', 'rain', 'Array(Nullable(Float64))') as rain,
        JSONExtract(data, 'hourly', 'snowfall', 'Array(Nullable(Float64))') as snowfall,
        JSONExtract(data, 'hourly', 'weather_code', 'Array(Nullable(Int64))') as weather_code,
        JSONExtract(data, 'hourly', 'wind_speed_10m', 'Array(Nullable(Float64))') as wind_speed_10m,
        JSONExtract(data, 'hourly', 'wind_gusts_10m', 'Array(Nullable(Float64))') as wind_gusts_10m,
        _sling_stream_url as source_file,
        _sling_loaded_at as sling_loaded_at
    from source
),

expanded_hours as (
    select
        hourly_row,
        timezone,
        source_file,
        sling_loaded_at
    from hourly_arrays
    array join arrayZip(
        hourly_time,
        temperature_2m,
        apparent_temperature,
        relative_humidity_2m,
        precipitation,
        rain,
        snowfall,
        weather_code,
        wind_speed_10m,
        wind_gusts_10m
    ) as hourly_row
)

select
    -- Parse local wall-clock values as UTC to avoid DST normalization for joins
    -- to timezone-naive NYC taxi timestamps; America/New_York remains metadata.
    parseDateTime64BestEffortOrNull(hourly_row.1, 0, 'UTC') as weather_datetime,
    timezone,
    hourly_row.2 as temperature_2m,
    hourly_row.3 as apparent_temperature,
    hourly_row.4 as relative_humidity_2m,
    hourly_row.5 as precipitation,
    hourly_row.6 as rain,
    hourly_row.7 as snowfall,
    hourly_row.8 as weather_code,
    hourly_row.9 as wind_speed_10m,
    hourly_row.10 as wind_gusts_10m,
    source_file,
    sling_loaded_at
from expanded_hours
