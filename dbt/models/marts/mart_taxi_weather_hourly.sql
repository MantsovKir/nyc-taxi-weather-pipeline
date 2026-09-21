{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='analysis_hour',
    partition_by='toYYYYMM(analysis_hour)',
    settings={'allow_nullable_key': 1}
) }}

with weather as (
    select *
    from {{ ref('stg_weather_hourly') }}
),

taxi as (
    select
        *,
        1 as taxi_row_exists
    from {{ ref('int_taxi_hourly') }}
)

select
    weather.weather_datetime as analysis_hour,
    toDate(weather.weather_datetime) as analysis_date,
    toStartOfMonth(weather.weather_datetime) as analysis_month,
    toYear(weather.weather_datetime) as analysis_year,
    toMonth(weather.weather_datetime) as analysis_month_number,
    toDayOfWeek(weather.weather_datetime) as day_of_week_number,
    toHour(weather.weather_datetime) as hour_of_day,
    if(day_of_week_number in (6, 7), 1, 0) as is_weekend,
    weather.timezone,
    weather.temperature_2m,
    weather.apparent_temperature,
    weather.relative_humidity_2m,
    weather.precipitation,
    weather.rain,
    weather.snowfall,
    weather.weather_code,
    weather.wind_speed_10m,
    weather.wind_gusts_10m,
    ifNull(taxi.taxi_row_exists, 0) as has_taxi_records,
    ifNull(taxi.total_trip_records, 0) as total_trip_records,
    ifNull(taxi.valid_trip_count, 0) as valid_trip_count,
    ifNull(taxi.invalid_trip_count, 0) as invalid_trip_count,
    ifNull(taxi.invalid_duration_count, 0) as invalid_duration_count,
    ifNull(taxi.zero_distance_count, 0) as zero_distance_count,
    ifNull(taxi.extreme_distance_count, 0) as extreme_distance_count,
    ifNull(taxi.missing_passenger_count, 0) as missing_passenger_count,
    ifNull(taxi.refund_or_correction_count, 0) as refund_or_correction_count,
    ifNull(taxi.total_passengers, 0) as total_passengers,
    ifNull(taxi.total_valid_distance, 0) as total_valid_distance,
    ifNull(taxi.total_valid_duration_minutes, 0) as total_valid_duration_minutes,
    ifNull(taxi.total_revenue, 0) as total_revenue,
    ifNull(taxi.total_tip_amount, 0) as total_tip_amount,
    -- Preserve NULL averages for unmatched hours with either join_use_nulls setting.
    if(has_taxi_records = 1, taxi.avg_trip_distance, NULL) as avg_trip_distance,
    if(has_taxi_records = 1, taxi.avg_trip_duration_minutes, NULL) as avg_trip_duration_minutes,
    if(has_taxi_records = 1, taxi.avg_trip_amount, NULL) as avg_trip_amount,
    ifNull(taxi.valid_trip_count, 0)
        / nullIf(ifNull(taxi.total_trip_records, 0), 0) as valid_trip_rate
from weather
left join taxi
    on weather.weather_datetime = taxi.pickup_hour
