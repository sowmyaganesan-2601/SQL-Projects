/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1


/* Q2: Which countries have the most Invoices? */

SELECT COUNT(*) AS Most_Invoices, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY Most_Invoices DESC


/* Q3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC
LIMIT 3


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city,SUM(total) AS Invoice_Total
FROM invoice
GROUP BY billing_city
ORDER BY Invoice_total DESC
LIMIT 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT c.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer c
JOIN invoice ON c.customer_id = invoice.customer_id
GROUP BY c.customer_id
ORDER BY total_spending DESC
LIMIT 1;




/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

/*Method 1 */

SELECT DISTINCT email,first_name, last_name
FROM customer c
JOIN invoice inv ON c.customer_id = inv.customer_id
JOIN invoice_line i ON inv.invoice_id = i.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track t
	JOIN genre g ON t.genre_id = g.genre_id
	WHERE g.name LIKE 'Rock'
)
ORDER BY email;


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track t
JOIN album ON album.album_id = t.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

/*Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name ,milliseconds from track
where milliseconds > (select AVG(milliseconds) from track)
order by milliseconds DESC

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

WITH best_selling_artist AS 
(
    SELECT artist.artist_id,artist.name,SUM(inv.unit_price * inv.quantity) as total_sales
	from  invoice_line inv 
	join track t on t.track_id = inv.track_id 
	join album a on a.album_id =t.album_id
	join artist on artist.artist_id=a.artist_id
    group by 1
	order by 3 desc
    limit 1
) 
select c.customer_id,c.first_name,c.last_name,bsa.artist_id,SUM(inv.unit_price * inv.quantity) AS total_sales
from customer c join invoice on c.customer_id=invoice.customer_id
join invoice_line inv on inv.invoice_id=invoice.invoice_id 
join track t on t.track_id=inv.track_id
join album a on a.album_id=t.album_id
join best_selling_artist bsa on bsa.artist_id=a.artist_id
group by c.customer_id,c.first_name,c.last_name,bsa.artist_id
order by total_sales desc


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */


	 
/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

WITH popular_genre AS 
(
    SELECT COUNT(i.quantity) AS purchases, c.country, g.name, g.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(i.quantity) DESC) AS Row_no 
    FROM invoice_line i
	JOIN invoice inv ON inv.invoice_id = i.invoice_id
	JOIN customer c  ON c.customer_id = inv.customer_id
	JOIN track t ON t.track_id = i.track_id
	JOIN genre g  ON g.genre_id = t.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
) 
select * from popular_genre where Row_no <=1



/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

WITH Customer_with_Country
AS (
select c.customer_id,c.first_name,c.last_name,i.billing_country,SUM(i.total) as total_spending,
ROW_NUMBER()OVER(PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS Row_no
from invoice i join customer c 
on c.customer_id = i.customer_id
group by 1,2,3,4
ORDER BY 4 ASC ,5 DESC )
SELECT * FROM Customer_with_Country where Row_no <=1

