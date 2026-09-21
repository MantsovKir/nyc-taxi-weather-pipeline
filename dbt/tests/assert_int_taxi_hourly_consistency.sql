select *
from {{ ref('int_taxi_hourly') }}
where total_trip_records != valid_trip_count + invalid_trip_count
   or valid_trip_count < 0
   or valid_trip_count > total_trip_records
   or invalid_trip_count < 0
   or invalid_trip_count > total_trip_records
   or invalid_duration_count < 0
   or invalid_duration_count > total_trip_records
   or zero_distance_count < 0
   or zero_distance_count > total_trip_records
   or extreme_distance_count < 0
   or extreme_distance_count > total_trip_records
   or missing_passenger_count < 0
   or missing_passenger_count > total_trip_records
   or refund_or_correction_count < 0
   or refund_or_correction_count > total_trip_records
