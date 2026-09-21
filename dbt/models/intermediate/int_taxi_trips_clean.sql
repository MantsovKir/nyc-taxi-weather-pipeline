with source as (
    select *
    from {{ ref('stg_taxi_trips') }}
    where pickup_datetime >= toDateTime64('2025-01-01 00:00:00', 6)
      and pickup_datetime < toDateTime64('2026-06-01 00:00:00', 6)
),

calculated as (
    select
        *,
        toStartOfHour(pickup_datetime) as pickup_hour,
        dateDiff('second', pickup_datetime, dropoff_datetime) / 60.0 as trip_duration_minutes
    from source
),

final as (
    select
        *,
        if(
            ifNull(
                dropoff_datetime > pickup_datetime
                and trip_duration_minutes <= 240,
                0
            ),
            1, 0
        ) as is_valid_duration,
        if(ifNull(trip_distance = 0, 0), 1, 0) as is_zero_distance,
        if(ifNull(trip_distance > 100, 0), 1, 0) as is_extreme_distance,
        if(isNull(passenger_count), 1, 0) as is_passenger_count_missing,
        if(
            ifNull(fare_amount < 0, 0) or ifNull(total_amount < 0, 0),
            1, 0
        ) as is_refund_or_correction,
        if(
            ifNull(
                dropoff_datetime > pickup_datetime
                and trip_duration_minutes <= 240
                and trip_distance > 0
                and trip_distance <= 100
                and fare_amount >= 0
                and total_amount >= 0,
                0
            ),
            1, 0
        ) as is_valid_trip
    from calculated
)

select *
from final
