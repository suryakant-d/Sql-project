use chinook;

-- objective question 1 solution

SET sql_safe_updates = 0;

UPDATE customer
SET Company = "Not Known"
WHERE Company is null;

UPDATE Customer
SET Fax = "Not Known"
WHERE Fax is null;

UPDATE track
SET Composer = "Not Known"
WHERE Composer is null;

SET sql_safe_updates = 1;

-- objective question solution 2

-- part 1 -top selling track and respective artist

SELECT 
    t.Name AS TrackName,
    ar.Name AS ArtistName,
    COUNT(il.Invoice_Line_Id) AS TotalSales
FROM Invoice i
JOIN Customer c ON i.Customer_Id = c.Customer_Id
JOIN Invoice_Line il ON i.Invoice_Id = il.Invoice_Id
JOIN Track t ON il.Track_Id = t.Track_Id
JOIN Album al ON t.Album_Id = al.Album_Id
JOIN Artist ar ON al.Artist_Id = ar.Artist_Id
WHERE c.Country = 'USA'
GROUP BY t.Track_Id
ORDER BY TotalSales DESC
LIMIT 5;

-- part 2 tot artist in usa

SELECT 
    ar.Name AS ArtistName,
    COUNT(il.Invoice_Line_Id) AS TotalSales
FROM Invoice i
JOIN Customer c ON i.Customer_Id = c.Customer_Id
JOIN Invoice_Line il ON i.Invoice_Id = il.Invoice_Id
JOIN Track t ON il.Track_Id = t.Track_Id
JOIN Album al ON t.Album_Id = al.Album_Id
JOIN Artist ar ON al.Artist_Id = ar.Artist_Id
WHERE c.Country = 'USA'
GROUP BY ar.Artist_Id
ORDER BY TotalSales DESC
limit 1;

-- part 3 -top genre in USA for Top Artist in USA

with Top_artist_USA as (
	SELECT 
		ar.Name AS ArtistName,
		COUNT(il.Invoice_Line_Id) AS TotalSales
	FROM Invoice i
	JOIN Customer c ON i.Customer_Id = c.Customer_Id
	JOIN Invoice_Line il ON i.Invoice_Id = il.Invoice_Id
	JOIN Track t ON il.Track_Id = t.Track_Id
	JOIN Album al ON t.Album_Id = al.Album_Id
	JOIN Artist ar ON al.Artist_Id = ar.Artist_Id
	WHERE c.Country = 'USA'
	GROUP BY ar.Artist_Id
	ORDER BY TotalSales DESC
    limit 1
)
SELECT 
    g.Name AS Genre,
	COUNT(il.Invoice_Line_Id) AS TotalSales
FROM Invoice i
JOIN Customer c ON i.Customer_Id = c.Customer_Id
JOIN Invoice_Line il ON i.Invoice_Id = il.Invoice_Id
JOIN Track t ON il.Track_Id = t.Track_Id
JOIN Genre g ON t.Genre_Id = g.Genre_Id
JOIN Album al ON t.Album_Id = al.Album_Id
JOIN Artist ar ON al.Artist_Id = ar.Artist_Id
WHERE c.Country = 'USA' and ar.name = (select ArtistName from Top_artist_USA)
group by g.genre_id
order by TotalSales desc; 

-- objective question 3 solution

select 
	country as country,
    count(distinct customer_id) as customer_count
from customer
group by country
order by country;


-- obejective question 4 solution

select
	billing_country as country_name,
    sum(total) as total_revenue,
    count(invoice_id) as inoice_count
from invoice
group by billing_country
order by billing_country ;

-- part 2

select
	billing_country,
	case
		when billing_state = "None" then concat(billing_country , "'s " , "State")
        else billing_state
    end as billing_state,
    sum(total) as total_revenue,
    count(invoice_id) as inoice_count
from invoice
group by billing_state , billing_country
order by billing_country , billing_state;

-- part 3

select
	billing_city as city_name,
    sum(total) as total_revenue,
    count(invoice_id) as inoice_count
from invoice
group by billing_city
order by billing_city ;

-- obejective question 5 solution

WITH top_customer as (
	select 
		i.billing_country as country,
        concat(c.first_name, " " , c.last_name) as customer_name,
        sum(i.total) total_revenue_each_customer,
        dense_rank() over (partition by billing_country order by sum(total) desc)  as ranking
	from invoice i
    join customer c 
    on i.customer_id = c.customer_id
	group by billing_country , customer_name
)
select 
	country,
    customer_name,
    total_revenue_each_customer
from top_customer
where ranking <= 5
order by country , total_revenue_each_customer desc;

-- objective question solution 6

with top_selling_track as (
	select 
		i2.customer_id,
        i1.track_id,
		sum(i2.total) as Total_Spending,
		dense_rank() over (partition by i2.customer_id order by sum(i2.total) desc) top_selling_track_id_rank
	from invoice_line i1
	join invoice i2
	on i1.invoice_id = i2.invoice_id 
	join track t1
	on i1.track_id = t1.track_id
	group by i2.customer_id , i1.track_id
)
select 
	(select concat(first_name , " " , last_name) from customer where customer_id = t.customer_id ) as customer_name,
    (select name from track where track_id = t.track_id)  as track_name,
    Total_Spending
from top_selling_track t
where top_selling_track_id_rank = 1
order by customer_name;

-- objective question 7 solution

SELECT 
    (select concat(first_name , " " , last_name) from customer where customer_id = i.customer_id) as customer_name,
    ROUND(AVG(Total), 2) AS AvgOrderValue,
    COUNT(Invoice_Id) AS NumberOfPurchases,
    ROUND(SUM(Total), 2) AS TotalSpent
FROM Invoice i
GROUP BY Customer_id
ORDER BY AvgOrderValue DESC;

-- objective question 8 solution
with year_wise_count as (
	select 
		year(invoice_date) as year,
		count(distinct customer_id) as customer_count
	from invoice
	group by year
)
select 
	year,
    customer_count as  at_the_end_of_year,
    coalesce(lag(customer_count) over (),"Not known") as  at_the_begining_of_year,
    coalesce(round(100*(lag(customer_count) over () - customer_count) / lag(customer_count) over () ,2) , "Not Known") as customer_churn_rate
from year_wise_count;

-- objective question solution 9

SELECT 
    g.Name AS Genre,
    ROUND(SUM(il.Unit_Price * il.Quantity), 2) AS GenreRevenue,
    ROUND(SUM(il.Unit_Price * il.Quantity) / (
        SELECT SUM(il2.Unit_Price * il2.Quantity)
        FROM Invoice i2
        JOIN Customer c2 ON i2.Customer_Id = c2.Customer_Id
        JOIN Invoice_Line il2 ON i2.Invoice_Id = il2.Invoice_Id
        WHERE c2.Country = 'USA'
    ) * 100, 2) AS PercentageOfTotalSales
FROM Invoice i
JOIN Customer c ON i.Customer_Id = c.Customer_Id
JOIN Invoice_Line il ON i.Invoice_Id = il.Invoice_Id
JOIN Track t ON il.Track_Id = t.track_id
JOIN Genre g ON t.Genre_ID= g.Genre_id
WHERE c.Country = 'USA'
GROUP BY g.Genre_Id
ORDER BY GenreRevenue DESC;

-- part 2 best artist in usa
SELECT 
    ar.Name AS Artist,
    ROUND(SUM(il.Unit_Price * il.Quantity), 2) AS TotalRevenue
FROM Invoice i
JOIN Customer c ON i.Customer_Id = c.Customer_Id
JOIN Invoice_Line il ON i.Invoice_Id = il.Invoice_Id
JOIN Track t ON il.Track_Id = t.Track_Id
JOIN Album al ON t.Album_Id = al.Album_Id
JOIN Artist ar ON al.Artist_Id = ar.Artist_Id
WHERE c.Country = 'USA'
GROUP BY ar.Artist_Id
ORDER BY TotalRevenue DESC
LIMIT 5;

-- objective question 10 solution

with different_genre as (
	select 
		i2.customer_id,
        count(distinct t1.genre_id) as genre_count
	from invoice_line i1
	join invoice i2
	on i1.invoice_id = i2.invoice_id 
	join track t1
	on i1.track_id = t1.track_id
    group by i2.customer_id
)
select 
	(select concat(first_name," ",last_name) from customer where  customer_id = d.customer_id) as Customer_Name,
    genre_count
from different_genre d
where genre_count >= 3
order by genre_count desc;

-- objective question solution 11

SELECT 
    g.Name AS Genre,
    ROUND(SUM(il.Unit_Price * il.Quantity), 2) AS TotalSalesUSD,
    RANK() OVER (ORDER BY SUM(il.Unit_Price * il.Quantity) DESC) AS SalesRank
FROM Invoice i
JOIN Customer c ON i.Customer_Id = c.Customer_Id
JOIN Invoice_Line il ON i.Invoice_Id = il.Invoice_Id
JOIN Track t ON il.Track_Id = t.Track_Id
JOIN Genre g ON t.Genre_Id = g.Genre_Id
WHERE c.Country = 'USA'
GROUP BY g.Genre_Id
ORDER BY TotalSalesUSD DESC;


-- objective question 12 solution

SELECT 
    c.Customer_Id,
    CONCAT(c.First_Name, ' ', c.Last_Name) AS CustomerName,
    MAX(i.Invoice_Date) AS LastPurchaseDate,
    DATEDIFF((select max(invoice_date) from invoice), MAX(i.Invoice_Date)) AS DaysSinceLastPurchase
FROM Customer c
LEFT JOIN Invoice i ON c.Customer_Id = i.Customer_Id
GROUP BY c.Customer_Id
HAVING DaysSinceLastPurchase > 90 OR LastPurchaseDate IS NULL
order by customer_id ;


                                                 -- SUBJECTIVE QUESTION SOLUTION

-- SUBJECTIVE QUESTION 1 SOLUTION

SELECT 
    al.Album_Id,
    al.Title AS AlbumTitle,
    ar.Name AS Artist_Name,
    ROUND(SUM(il.Unit_Price * il.Quantity), 2) AS TotalSalesUSD,
    g.Name AS Genre
FROM Invoice_Line il
JOIN Invoice i ON il.Invoice_Id = i.Invoice_Id
JOIN Customer c ON i.Customer_Id = c.Customer_Id
JOIN Track t ON il.Track_Id = t.Track_Id
JOIN Album al ON t.Album_Id = al.Album_Id
JOIN Artist ar ON al.Artist_Id = ar.Artist_Id
JOIN Genre g ON t.Genre_Id = g.Genre_Id
WHERE c.Country = 'USA'
GROUP BY al.Album_Id , al.Title , ar.Name , g.Name
ORDER BY TotalSalesUSD DESC
LIMIT 3;

-- SUBJECTIVE QUESTION 2 SOLUTION 


WITH TOP_GENRE AS (
	SELECT
		c.Country,
		g.Name AS Genre,
		ROUND(SUM(il.Unit_Price * il.Quantity), 2) AS TotalSales,
		RANK() OVER (PARTITION BY c.Country ORDER BY ROUND(SUM(il.Unit_Price * il.Quantity),2) DESC) AS genre_rank
	FROM Customer c
	JOIN Invoice i ON c.Customer_Id = i.Customer_Id
	JOIN Invoice_Line il ON i.Invoice_Id = il.Invoice_Id
	JOIN Track t ON il.Track_Id = t.Track_Id
	JOIN Genre g ON t.Genre_Id = g.Genre_Id
	WHERE c.Country != 'USA'
	GROUP BY c.Country, g.Name
	ORDER BY c.Country, TotalSales DESC
)
SELECT 
	Country,
    Genre,
    TotalSales
FROM TOP_GENRE
WHERE genre_rank = 1
ORDER BY Country;

-- for usa top genre 

select 
		i2.billing_country as country,
		t1.genre_id,
        (select name from genre where genre_id = t1.genre_id) as genre_name,
        sum(i1.Unit_Price*i1.Quantity) total_revenue_each_genre
	from invoice_line i1
	join invoice i2
	on i1.invoice_id = i2.invoice_id 
	join track t1
	on i1.track_id = t1.track_id
    where i2.billing_country = "USA"
    group by t1.genre_id , genre_name  , country
    order by total_revenue_each_genre desc
    limit 1;
    
-- subjective question 3 solution
WITH CustomerFirstPurchase AS (
    SELECT 
        c.Customer_Id,
        year(Max(I.Invoice_Date))-Year(MIN(i.Invoice_Date)) AS year_frequency
    FROM Customer c
    JOIN Invoice i ON c.Customer_Id = i.Customer_Id
    GROUP BY c.Customer_Id
),
CustomerSegment AS (
    SELECT 
        Customer_Id,
        case
			when year_frequency = (select max(year(invoice_date)) - min(year(invoice_date)) from invoice) then "long_term_customer"
			else "new_customer"
		end as type_of_customer
    FROM CustomerFirstPurchase
)
SELECT 
    cs.type_of_customer,
    COUNT(DISTINCT i.Invoice_Id) AS PurchaseFrequency,
    ROUND(AVG(il.Quantity), 2) AS AvgBasketSize,
    ROUND(SUM(i.Total), 2) AS TotalSpending,
    ROUND(AVG(i.Total), 2) AS AvgSpendingPerInvoice
FROM CustomerSegment cs
JOIN Invoice i ON cs.Customer_Id = i.Customer_Id
JOIN Invoice_Line il ON i.Invoice_Id = il.Invoice_Id
WHERE cs.type_of_customer IN ("long_term_customer", "new_customer")
GROUP BY cs.type_of_customer;



-- subjective question 4 solution

-- frequent_track as

SELECT 
    (select name from track where track_id = il1.track_id)AS Track1, 
    (select name from track where track_id = il2.track_id) AS Track2, 
    COUNT(*) AS Frequency
FROM Invoice_Line il1
JOIN Invoice_Line il2 
    ON il1.Invoice_Id = il2.Invoice_Id 
    AND il1.Track_Id < il2.Track_Id
GROUP BY il1.Track_Id, il2.Track_Id
ORDER BY Frequency DESC
LIMIT 10;

-- frequent_album as 

SELECT 
	(select title from album where album_id = t1.album_id) AS Album1, 
    (select title from album where album_id = t2.album_id) AS Album2, 
    COUNT(*) AS Frequency
FROM Invoice_Line il1
JOIN Invoice_Line il2 
    ON il1.Invoice_Id = il2.Invoice_Id
JOIN Track t1 ON il1.Track_Id = t1.Track_Id
JOIN Track t2 ON il2.Track_Id = t2.Track_Id
WHERE t1.Album_Id < t2.Album_Id
GROUP BY t1.Album_Id, t2.Album_Id
ORDER BY Frequency DESC
LIMIT 10;


-- frequent_genre as 

SELECT 
    g1.Name AS Genre1, 
    g2.Name AS Genre2, 
    COUNT(*) AS Frequency
FROM Invoice_Line il1
JOIN Invoice_Line il2 
    ON il1.Invoice_Id = il2.Invoice_Id
JOIN Track t1 ON il1.Track_Id = t1.Track_Id
JOIN Track t2 ON il2.Track_Id = t2.Track_Id
JOIN Genre g1 ON t1.Genre_Id = g1.Genre_Id
JOIN Genre g2 ON t2.Genre_Id = g2.Genre_Id
WHERE g1.Genre_Id < g2.Genre_Id
GROUP BY g1.Name, g2.Name
ORDER BY Frequency DESC
LIMIT 10;

-- SUBJECTIVE QUESTION 5 SOLUTION

SELECT 
    c.Country, 
    COUNT(i.Invoice_Id) AS TotalPurchases, 
    ROUND(AVG(i.Total), 2) AS AvgSpendingPerPurchase,
    ROUND(SUM(i.Total), 2) AS TotalRevenue
FROM Customer c
JOIN Invoice i ON c.Customer_Id = i.Customer_Id
GROUP BY c.Country
ORDER BY TotalRevenue DESC;

-- PART 2

WITH LastPurchase AS (
  SELECT 
    Customer_Id,
    MAX(Invoice_Date) AS LastInvoiceDate
  FROM Invoice
  GROUP BY Customer_Id
),
ChurnStatus AS (
  SELECT 
    c.Customer_Id,
    c.Country,
    CASE 
      WHEN lp.LastInvoiceDate < DATE_sub((select max(invoice_date) from invoice), interval 6 month) THEN 1
      ELSE 0
    END AS IsChurned
  FROM Customer c
  LEFT JOIN LastPurchase lp ON c.Customer_Id = lp.Customer_Id
)
SELECT 
  Country,
  COUNT(Customer_Id) AS TotalCustomers,
  SUM(IsChurned) AS ChurnedCustomers,
  ROUND(100.0 * SUM(IsChurned) / COUNT(Customer_Id), 2) AS ChurnRate_Percent
FROM ChurnStatus
GROUP BY Country
ORDER BY ChurnRate_Percent DESC;

-- SUBJECTIVE QUESTION 6 SOLUTION

WITH rfm_base AS (
  SELECT
    c.Customer_Id,
    c.Country,
    MAX(i.Invoice_Date) AS LastInvoiceDate,
    COUNT(i.Invoice_Id) AS Frequency,
    SUM(i.Total) AS Monetary
  FROM Customer c
  LEFT JOIN Invoice i ON c.Customer_Id = i.Customer_Id
  GROUP BY c.Customer_Id, c.Country
),
rfm_features AS (
  SELECT
    (select concat(firsT_name , " " ,last_name )from customer where customer_id = r.customer_id) as customer_name,
    Country,
    DATEDIFF((SELECT MAX(INVOICE_DATE) FROM INVOICE), LastInvoiceDate) AS Recency,
    Frequency,
    Monetary
  FROM rfm_base r
)
SELECT * FROM rfm_features;

-- RISK_FIGURING
WITH rfm_base AS (
  SELECT
    c.Customer_Id,
    c.Country,
    MAX(i.Invoice_Date) AS LastInvoiceDate,
    COUNT(i.Invoice_Id) AS Frequency,
    SUM(i.Total) AS Monetary
  FROM Customer c
  LEFT JOIN Invoice i ON c.Customer_Id = i.Customer_Id
  GROUP BY c.Customer_Id, c.Country
),
rfm_features AS (
  SELECT
    Customer_Id,
    Country,
    DATEDIFF((SELECT MAX(INVOICE_DATE) FROM INVOICE), LastInvoiceDate) AS Recency,
    Frequency,
    Monetary
  FROM rfm_base
),
risk_tags AS (
  SELECT *,
    CASE
      WHEN Recency > 180 AND (Frequency <= 2 OR Monetary < 20) THEN 'High Risk'
      WHEN Recency > 90 OR Frequency <= 3 OR Monetary < 40 THEN 'Medium Risk'
      ELSE 'Low Risk'
    END AS RiskSegment
  FROM rfm_features
)
SELECT * FROM risk_tags;


-- part 3

SELECT 
  Country,
  RiskSegment,
  COUNT(*) AS NumCustomers,
  ROUND(AVG(Recency), 0) AS AvgRecency,
  ROUND(AVG(Frequency), 1) AS AvgFrequency,
  ROUND(AVG(Monetary), 2) AS AvgMonetary
FROM (
  -- Use the "risk_tags" query as a subquery
  SELECT
    c.Customer_Id,
    c.Country,
    DATEDIFF((select max(invoice_date) from invoice), MAX(i.Invoice_Date)) AS Recency,
    COUNT(i.Invoice_Id) AS Frequency,
    SUM(i.Total) AS Monetary,
    CASE
      WHEN DATEDIFF((select max(invoice_date) from invoice), MAX(i.Invoice_Date)) > 180 AND 
           (COUNT(i.Invoice_Id) <= 2 OR SUM(i.Total) < 20) THEN 'High Risk'
      WHEN DATEDIFF((select max(invoice_date) from invoice), MAX(i.Invoice_Date)) > 90 OR 
           COUNT(i.Invoice_Id) <= 3 OR SUM(i.Total) < 40 THEN 'Medium Risk'
      ELSE 'Low Risk'
    END AS RiskSegment
  FROM Customer c
  LEFT JOIN Invoice i ON c.Customer_Id = i.Customer_Id
  GROUP BY c.Customer_Id, c.Country
) AS risk_data
GROUP BY Country, RiskSegment
ORDER BY Country, FIELD(RiskSegment, 'High Risk', 'Medium Risk', 'Low Risk');


-- SUBJECTIVE QUESTION 7 SOLUTION
with estimated_clv as (
	SELECT 
		i.billing_country as country,
		(select concat(first_name , " " , last_name) from customer where customer_id = i.customer_id) as customer_name,
        sum(i.total) as Total_spending,
		ROUND(AVG(i.Total), 2) AS AvgPurchaseValue,
		COUNT(i.Invoice_Id) AS NumPurchases,
		DATEDIFF(MAX(i.Invoice_Date), MIN(i.Invoice_Date)) AS LifespanDays,
        DATEDIFF((select max(invoice_date) from invoice),MAX(i.Invoice_Date)) as last_purchase_interval,
		ROUND(AVG(i.Total) * COUNT(i.Invoice_Id)*DATEDIFF(MAX(i.Invoice_Date), MIN(i.Invoice_Date))/365, 2) AS ApproxCLV
	FROM Invoice i
	GROUP BY i.Customer_Id ,country
)
SELECT *,
       CASE
           WHEN ApproxCLV > 350 THEN 'High Value'
           WHEN ApproxCLV BETWEEN 250 AND 350 THEN 'Medium Value'
           ELSE 'Low Value'
       END AS CLVSegment
FROM estimated_clv
order by ApproxCLV desc ;

-- SUBJECTIVE QUESTION 10 SOLUTION

ALTER TABLE Album
ADd COLUMN RleaseYear int;

select * from album;

-- SUBJECTIVE QUESTION 11 SOLUTION

SELECT 
	I1.BILLING_COUNTRY AS COUNTRY,
    ROUND(AVG(I1.TOTAL) , 2) AS AVG_TOTAL_SPENT,
    COUNT(DISTINCT I1.CUSTOMER_ID) AS CUSTOMER_COUNT,
    ROUND(COUNT(DISTINCT I2.INVOICE_LINE_ID) / COUNT(DISTINCT I1.CUSTOMER_ID) , 2) AS AVG_TRACK_PER_CUSTOMER
FROM INVOICE I1
JOIN INVOICE_LINE I2
ON I1.INVOICE_ID = I2.INVOICE_ID
GROUP BY COUNTRY;