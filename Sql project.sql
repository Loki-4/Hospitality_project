SET GLOBAL local_infile = 1;
create database Hospitality;
use  Hospitality;
drop table dim_date;
CREATE TABLE dim_date (
    date DATE NOT NULL,
    mmm_yy VARCHAR(10),
    week_no INT,
    day_type ENUM('weekend', 'weekday')
);
CREATE TABLE dim_rooms (
    room_id VARCHAR(10) PRIMARY KEY,
    room_class ENUM('Standard', 'Elite', 'Premium', 'Presidential')
);
CREATE TABLE dim_hotels (
    property_id INT PRIMARY KEY,
    property_name VARCHAR(255),
    category ENUM('Luxury', 'Business'),
    city VARCHAR(100)
);
CREATE TABLE fact_aggregated_bookings (
    property_id INT,
    check_in_date DATE,
    room_category VARCHAR(10),
    successful_bookings INT,
    capacity INT,
    FOREIGN KEY (property_id) REFERENCES dim_hotels(property_id)
);
CREATE TABLE fact_bookings (
    booking_id varchar(123) PRIMARY KEY,
    property_id INT,
    booking_date DATE,
    check_in_date DATE,
    check_out_date DATE,
    no_guests INT,
    room_category VARCHAR(10),
    booking_platform VARCHAR(50),
    ratings_given DECIMAL(3, 0),
    booking_status ENUM('Cancelled', 'Checked Out', 'No Show'),
    revenue_generated DECIMAL(10, 0),
    revenue_realized DECIMAL(10, 0),
    FOREIGN KEY (property_id) REFERENCES dim_hotels(property_id)
);
select * from dim_rooms;
select * from dim_hotels;
select * from dim_date;
select * from fact_aggregated_bookings;
select * from fact_bookings;
 
 Load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\fact_bookings.csv" 
 into table fact_bookings 
 fields terminated by ","
 ignore 1 lines;
SHOW VARIABLES LIKE 'secure_file_priv';

-- q1 : Total Revenue By month (ctrl+/)

SELECT 
    month(check_in_date), SUM(revenue_generated) AS total_revenue
FROM 
    fact_bookings
Group by month(check_in_date);

-- q2 : Occupancy rate
SELECT 
    month(d.date),
    SUM(fa.successful_bookings) / SUM(fa.capacity) * 100 AS occupancy_rate
FROM 
    fact_aggregated_bookings fa
JOIN 
    dim_date d ON fa.check_in_date = d.date
GROUP BY 
    month(d.date);
    
-- q3 Cancellation rate by month
SELECT 
    month(d.date),
    (count(CASE WHEN fb.booking_status = 'Cancelled' THEN 1 END) / COUNT(fb.booking_id)) * 100 AS cancellation_rate
FROM 
    fact_bookings fb
JOIN 
    dim_date d ON fb.booking_date = d.date
GROUP BY 
    month(d.date);
    
-- q4 : Total Bookings
SELECT 
    month(fb.check_in_date) ,COUNT(fb.booking_id) AS total_bookings
FROM 
    fact_bookings fb
GROUP BY 
    month(fb.check_in_date);
    
-- q5 : Utilize Capacity by month
SELECT 
   month(d.date),
    SUM(fa.successful_bookings) / SUM(fa.capacity) * 100 AS utilized_capacity
FROM 
    fact_aggregated_bookings fa
JOIN 
    dim_date d ON fa.check_in_date = d.date
GROUP BY 
    month(d.date);
    
SELECT 
    month(fa.check_in_date),
    SUM(fa.successful_bookings) / SUM(fa.capacity) * 100 AS utilized_capacity
FROM 
    fact_aggregated_bookings fa
GROUP BY 
    month(fa.check_in_date);

-- q6 Trend Analysis

SELECT 
    month(d.date) AS month_no,
    SUM(fb.revenue_generated) AS total_revenue,
    COUNT(fb.booking_id) AS total_bookings,
    SUM(fa.successful_bookings) / SUM(fa.capacity) * 100 AS occupancy_rate
FROM 
    fact_bookings fb
JOIN 
    dim_date d ON fb.booking_date = d.date
JOIN 
    fact_aggregated_bookings fa ON fb.check_in_date = fa.check_in_date
GROUP BY 
    month(d.date);
    
-- q7 : Weekday & Weekend Revenue and Booking

SELECT 
    month(fb.check_in_date),
    d.day_type,
    SUM(fb.revenue_generated) AS total_revenue,
    COUNT(fb.booking_id) AS total_bookings
FROM 
    fact_bookings fb
JOIN 
    dim_date d ON fb.booking_date = d.date
GROUP BY 
    d.day_type, month(fb.check_in_date);
    
-- q8 :Revenue by State & Hotel
SELECT 
    month(fb.check_in_date) as month_no,
    dh.city,
    dh.property_name,
    SUM(fb.revenue_generated) AS total_revenue
FROM 
    fact_bookings fb
JOIN 
    dim_hotels dh ON fb.property_id = dh.property_id
GROUP BY 
    dh.city, dh.property_name,month(fb.check_in_date);
    
-- q9 : Class_wise Revenue
SELECT
    month(fb.check_in_date) as month_no, 
    dr.room_class,
    SUM(fb.revenue_generated) AS total_revenue
FROM 
    fact_bookings fb
JOIN 
    dim_rooms dr ON fb.room_category = dr.room_id
GROUP BY 
    dr.room_class , month(fb.check_in_date) ;
    
-- q10 : Booking Status: Checked Out, Cancelled, No Show

SELECT 
     month(fb.check_in_date) as month_no,
    fb.booking_status,
    COUNT(fb.booking_id) AS total_bookings
FROM 
    fact_bookings fb
GROUP BY 
    fb.booking_status , month(fb.check_in_date);
    
-- q11 Weekly Trend Analysis (Revenue, Total Booking, Occupancy)

SELECT 
    CAST(SUBSTRING(d.week_no, 2) AS unsigned) AS week_number,
    SUM(fb.revenue_generated) AS total_revenue,
    COUNT(fb.booking_id) AS total_bookings,
    SUM(fa.successful_bookings) / SUM(fa.capacity) * 100 AS occupancy_rate
FROM 
    fact_bookings fb
JOIN 
    dim_date d ON fb.booking_date = d.date
JOIN 
    fact_aggregated_bookings fa ON fb.check_in_date = fa.check_in_date
where 
    CAST(SUBSTRING(d.week_no, 2) AS unsigned) between 19 and 23
GROUP BY 
    week_number;








    

















   
