select *
from {{ ref('mart_taxi_weather_hourly') }}
where ifNull(total_trip_records != valid_trip_count + invalid_trip_count, 1)
   or valid_trip_rate < 0
   or valid_trip_rate > 1
   or (
       total_trip_records > 0
       and (
           valid_trip_rate is null
           or abs(valid_trip_rate - valid_trip_count / nullIf(total_trip_records, 0)) > 0.000000001
       )
   )
   or (has_taxi_records = 1 and total_trip_records = 0)
   or (
       has_taxi_records = 0
       and (
           ifNull(total_trip_records != 0, 1)
           or ifNull(valid_trip_count != 0, 1)
           or ifNull(invalid_trip_count != 0, 1)
           or ifNull(invalid_duration_count != 0, 1)
           or ifNull(zero_distance_count != 0, 1)
           or ifNull(extreme_distance_count != 0, 1)
           or ifNull(missing_passenger_count != 0, 1)
           or ifNull(refund_or_correction_count != 0, 1)
           or ifNull(total_passengers != 0, 1)
           or ifNull(total_valid_distance != 0, 1)
           or ifNull(total_valid_duration_minutes != 0, 1)
           or ifNull(total_revenue != 0, 1)
           or ifNull(total_tip_amount != 0, 1)
           or avg_trip_distance is not null
           or avg_trip_duration_minutes is not null
           or avg_trip_amount is not null
           or valid_trip_rate is not null
       )
   )
   or ifNull(analysis_date != toDate(analysis_hour), 1)
   or ifNull(analysis_month != toStartOfMonth(analysis_hour), 1)
   or ifNull(analysis_year != toYear(analysis_hour), 1)
   or ifNull(analysis_month_number != toMonth(analysis_hour), 1)
   or ifNull(day_of_week_number != toDayOfWeek(analysis_hour), 1)
   or ifNull(hour_of_day != toHour(analysis_hour), 1)
