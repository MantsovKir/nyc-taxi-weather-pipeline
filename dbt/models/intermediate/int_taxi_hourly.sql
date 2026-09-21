with source as (
    select *
    from {{ ref('int_taxi_trips_clean') }}
)

select
    pickup_hour,
    count() as total_trip_records,
    countIf(is_valid_trip = 1) as valid_trip_count,
    countIf(is_valid_trip = 0) as invalid_trip_count,
    countIf(is_valid_duration = 0) as invalid_duration_count,
    countIf(is_zero_distance = 1) as zero_distance_count,
    countIf(is_extreme_distance = 1) as extreme_distance_count,
    countIf(is_passenger_count_missing = 1) as missing_passenger_count,
    countIf(is_refund_or_correction = 1) as refund_or_correction_count,
    sumIf(ifNull(passenger_count, 0), is_valid_trip = 1) as total_passengers,
    sumIf(trip_distance, is_valid_trip = 1) as total_valid_distance,
    sumIf(trip_duration_minutes, is_valid_trip = 1) as total_valid_duration_minutes,
    avgIf(trip_distance, is_valid_trip = 1) as avg_trip_distance,
    avgIf(trip_duration_minutes, is_valid_trip = 1) as avg_trip_duration_minutes,
    sumIf(total_amount, is_valid_trip = 1) as total_revenue,
    avgIf(total_amount, is_valid_trip = 1) as avg_trip_amount,
    sumIf(tip_amount, is_valid_trip = 1) as total_tip_amount
from source
group by pickup_hour
