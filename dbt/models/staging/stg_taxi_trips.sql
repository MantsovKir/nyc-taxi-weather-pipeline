with source as (
    select *
    from {{ source('raw', 'raw_taxi_trips') }}
)

select
    vendor_id,
    tpep_pickup_datetime as pickup_datetime,
    tpep_dropoff_datetime as dropoff_datetime,
    passenger_count,
    trip_distance,
    ratecode_id,
    store_and_fwd_flag,
    pulocation_id as pickup_location_id,
    dolocation_id as dropoff_location_id,
    payment_type,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount,
    congestion_surcharge,
    airport_fee,
    cbd_congestion_fee,
    _sling_stream_url as source_file,
    _sling_loaded_at as sling_loaded_at
from source
