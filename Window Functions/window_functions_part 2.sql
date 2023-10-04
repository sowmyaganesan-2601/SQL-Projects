select * from demand 
order by day
--Window Functions
--Q1) From demand table find cumulative sum of quantity
select days,quantity ,sum(quantity) over(order by days) as cum_quantity
from demand

--Q2) Find the running cumulative total demand by product.
SELECT product,day,qty ,sum(qty)over(partition by product order by day ) as cum_product_quantity
from demand

--Q3) What are the top 2 worst performing days for each product?
with product_perform as 
(
SELECT *,ROW_NUMBER()OVER(PARTITION BY product ORDER BY qty) as worst_performing_product
from demand
)
select * from product_perform 
where worst_performing_product <=2

--Q4) Find the percentage increase in qty compared to the previous day.
with quantity as (
 SELECT * ,lag(qty,1)over(partition by product order by day) as qty_lag 
 FROM demand 
)
select * ,round(cast(((qty-qty_lag)/qty_lag)*100 as numeric),2) as qty_percent_increase from quantity
where qty_lag is  not null;

--Q5) Show the minimum and maximum ‘qty’ sold for each product as separate columns.
With min_quantity as
(
select *,min(qty)over(partition by product) as min_qty_sold
from demand)
 select *,max(qty)over(partition by product ) as max_qty_sold
 from min_quantity
 
 --Q6) Calculate the difference between the second largest and the second smallest sales qty in each product
 WITH row_num as (
 SELECT *,ROW_NUMBER()OVER(partition by product  ) AS row_number ,
	  count(*) over (partition by product) as total_recs
 from demand
	 )
select * from row_num
where row_number=2 or row_number=(total_recs-1)

 --Q7) which days each product had the highest sales?
with high_prod as
( select * ,max(qty)OVER(PARTITION BY day) as max_qty
 from demand
 )
 select * from high_prod  
 
 --Q8)  What is the total sales from Top 3 products in each location?
WITH high_sales as(
SELECT *,ROW_NUMBER()OVER(PARTITION BY location order by sales desc  ) as row_num
 from sales 
 )
 select * from high_sales 
 where row_num<=3
 --Q9) Which products contribute to top 80% of total sales?
 with total_sales_cte as (
 select product,sum(sales) as total_sales
 from sales
 group by product
 order by total_sales
),
 cum_total_sales_cte as (
select product,total_sales,sum(total_sales)over(order by total_sales) as cum_total_sales
from total_sales_cte
),
sales_cte as(
select product,cum_total_sales,sum(total_sales)over() as total_sales
from cum_total_sales_cte
)
select *, round(cum_total_sales/total_sales,2) as cum_perc_sales
from sales_cte
where round(cum_total_sales/total_sales,2)<=0.8

--Q10)Create row numbers in increasing order of sales with each location
select * ,row_number()over(partition by location order by sales) as row_num
from sales

--Q11) Find the top products (Rank 1 and 2) within each location
with top_products_cte as(
SELECT * ,row_number()over(partition by location order by sales desc) as top_products
from sales
)
select * from top_products_cte
where top_products <=2




