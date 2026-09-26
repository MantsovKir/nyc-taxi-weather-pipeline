SELECT
    pickup_location_id,
    dropoff_location_id,
    pickup_hour,
    is_valid_trip
FROM {{ ref('mart_taxi_routes_hourly') }}
group by
    pickup_location_id,
    dropoff_location_id,
    pickup_hour,
    is_valid_trip
having count(*) > 1