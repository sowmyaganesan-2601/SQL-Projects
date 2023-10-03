select * from bookings
select max(price) as max_price from bookings
--Window Functions with OVER
----Q1) Average price with OVER

select booking_id,listing_name,neighbourhood_group ,
AVG(price) OVER() as avg_price
FROM bookings

--Q2) Average, minimum and maximum price with OVER
select booking_id,listing_name,neighbourhood_group,
AVG(price) OVER() as avg_price,
MIN(price) OVER() as min_price,
MAX(price) OVER() as max_price
from bookings

-- Q3) Difference from average price with OVER
SELECT booking_id,listing_name,neighbourhood_group,price,
ROUND(AVG(price) OVER(),2) ,
ROUND((price-AVG(price) OVER()),2) AS diff_price
from bookings

--Q4) Percent of average price with OVER()
SELECT booking_id,listing_name,neighbourhood_group,price,
ROUND(AVG(price) OVER(),2) as avg_price,
ROUND((price/AVG(price) OVER()*100),2) as perc_avg_price
FROM bookings

--PARTITION BY
--Q5) Partition by neighbourhood group
SELECT booking_id,listing_name,neighbourhood_group,neighbourhood,price,
AVG(price)OVER(PARTITION BY neighbourhood_group) AS avg_price_by_neigh_group
from bookings

--Q6) Partition by neighbourhood group and neighbourhood 
SELECT booking_id,listing_name,neighbourhood_group,neighbourhood,price,
AVG(price)OVER(PARTITION BY neighbourhood_group) AS avg_price_by_neigh_group,
AVG(price)OVER(PARTITION BY neighbourhood_group,neighbourhood) AS avg_price_neigh
from bookings

--Q7) Partition by neighbourhood group,neighbourhood and neighbourhood delta
SELECT booking_id,listing_name,neighbourhood_group,neighbourhood,price,
AVG(price)OVER(PARTITION BY neighbourhood_group) AS avg_price_by_neigh_group,
AVG(price)OVER(PARTITION BY neighbourhood_group,neighbourhood) AS avg_price_neigh,
ROUND((price-AVG(price)OVER(PARTITION BY neighbourhood_group)),2) AS neigh_group_delta,
ROUND((price-AVG(price)OVER(PARTITION BY neighbourhood_group,neighbourhood)),2) AS group_and_neigh_delta
from bookings

--Q8) Overall price rank 
SELECT booking_id,listing_name,neighbourhood_group,neighbourhood,price,
ROW_NUMBER()OVER(ORDER BY price desc) as overall_price_rank
from bookings

--Q9) neighbourhood price rank
SELECT booking_id,listing_name,neighbourhood_group,neighbourhood,price,
ROW_NUMBER()OVER(ORDER BY price desc) as overall_price_rank,
ROW_NUMBER()OVER(PARTITION BY neighbourhood_group ORDER BY price desc) AS neigh_group_price_rank
from bookings

---- Q10) Top 3
SELECT booking_id,listing_name,neighbourhood_group,neighbourhood,price,
ROW_NUMBER()OVER(ORDER BY price DESC) AS overall_price_rank,
ROW_NUMBER()OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank,
case 
    when ROW_NUMBER()OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) <=3 then 'Yes'
	ELSE 'No'
	end as top3_flag
	from bookings;
	
---Q11) RANK
SELECT booking_id,neighbourhood_group,price,
ROW_NUMBER()OVER(ORDER BY price DESC ) AS overall_price_rank,
RANK()OVER(ORDER BY price DESC) as overall_price_rank_with_rank,
ROW_NUMBER()OVER(PARTITION BY neighbourhood_group ORDER BY price DESC ) AS neigh_group_price_rank,
RANK()OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank_with_rank
from bookings

--Q12) -- DENSE_RANK
SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	neighbourhood,
	price,
	ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
	RANK() OVER(ORDER BY price DESC) AS overall_price_rank_with_rank,
	DENSE_RANK() OVER(ORDER BY price DESC) AS overall_price_rank_with_dense_rank
FROM bookings;

--Q13)-- LAG BY 1 period
SELECT
	booking_id,
	listing_name,
	host_name,
	price,
	last_review,
	LAG(price) OVER(PARTITION BY host_name ORDER BY last_review)
FROM bookings;

---- Q14) LAG BY 2 periods
SELECT
	booking_id,
	listing_name,
	host_name,
	price,
	last_review,
	LAG(price, 2) OVER(PARTITION BY host_name ORDER BY last_review)
FROM bookings;

--Q15) LEAD by 1 period
SELECT
	booking_id,
	listing_name,
	host_name,
	price,
	last_review,
	LEAD(price) OVER(PARTITION BY host_name ORDER BY last_review)
FROM bookings;

--Q16)  LEAD by 2 periods
SELECT
	booking_id,
	listing_name,
	host_name,
	price,
	last_review,
	LEAD(price, 2) OVER(PARTITION BY host_name ORDER BY last_review)
FROM bookings;

--Q17) Top 3 with subquery to select only the 'Yes' values in the top3_flag column
SELECT * FROM(
SELECT booking_id,listing_name,neighbourhood_group,neighbourhood,price,
ROW_NUMBER()OVER(ORDER BY price DESC ) as  overall_price_rank,
ROW_NUMBER()OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) as neigh_group_price_rank,
case 
	when ROW_NUMBER()OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) <=3 THEN 'Yes'
	ELSE 'No'
	END AS Top3_flag
	from bookings) a
where Top3_flag='Yes'