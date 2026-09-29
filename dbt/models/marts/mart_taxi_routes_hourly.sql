
{{ config(
    engine='MergeTree()',
    order_by='(pickup_hour, pickup_location_id, dropoff_location_id, is_valid_trip)',
    partition_by='toYYYYMM(pickup_hour)',
    settings={'allow_nullable_key': 1}
) }}

WITH taxi_trips AS (
    SELECT
        pickup_hour,
        pickup_location_id,
        dropoff_location_id,
        is_valid_trip,
        total_amount
    from {{ ref('int_taxi_trips_clean') }}
),
route_counts AS(
SELECT
    pickup_hour,
    pickup_location_id,
    dropoff_location_id,
    is_valid_trip,
    count() AS trip_count,
    sumIf(ifNull(total_amount, 0), is_valid_trip = 1) AS total_valid_amount
FROM taxi_trips
GROUP BY
    pickup_hour,
    pickup_location_id,
    dropoff_location_id,
    is_valid_trip
)
SELECT
    r.*,
    p.borough AS pickup_borough,
    p.zone AS pickup_zone,
    p.service_zone AS pickup_service_zone,
    d.borough AS dropoff_borough,
    d.zone AS dropoff_zone,
    d.service_zone AS dropoff_service_zone
FROM route_counts r
    LEFT JOIN {{ ref('taxi_zone_lookup') }} p
        ON r.pickup_location_id = p.location_id
    LEFT JOIN {{ ref('taxi_zone_lookup') }} d
        ON r.dropoff_location_id = d.location_id
