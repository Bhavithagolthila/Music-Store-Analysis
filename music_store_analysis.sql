-- ============================================================
-- MUSIC STORE SALES ANALYSIS
-- Database: music_store_analysis
-- SQL Dialect: MySQL
-- ============================================================

CREATE DATABASE IF NOT EXISTS music_store_analysis;
USE music_store_analysis;

-- ============================================================
-- 1. TABLE CREATION
-- ============================================================

CREATE TABLE IF NOT EXISTS artist (
    ArtistId INT PRIMARY KEY,
    Name VARCHAR(120)
);

CREATE TABLE IF NOT EXISTS album (
    AlbumId INT PRIMARY KEY,
    Title VARCHAR(160),
    ArtistId INT,
    FOREIGN KEY (ArtistId) REFERENCES artist(ArtistId)
);

CREATE TABLE IF NOT EXISTS genre (
    GenreId INT PRIMARY KEY,
    Name VARCHAR(120)
);

CREATE TABLE IF NOT EXISTS media_type (
    MediaTypeId INT PRIMARY KEY,
    Name VARCHAR(120)
);

CREATE TABLE IF NOT EXISTS track (
    TrackId INT PRIMARY KEY,
    Name VARCHAR(200),
    AlbumId INT,
    MediaTypeId INT,
    GenreId INT,
    Composer VARCHAR(220),
    Milliseconds INT,
    Bytes INT,
    UnitPrice DECIMAL(10,2),
    FOREIGN KEY (AlbumId) REFERENCES album(AlbumId),
    FOREIGN KEY (MediaTypeId) REFERENCES media_type(MediaTypeId),
    FOREIGN KEY (GenreId) REFERENCES genre(GenreId)
);

CREATE TABLE IF NOT EXISTS employee (
    EmployeeId INT PRIMARY KEY,
    LastName VARCHAR(20),
    FirstName VARCHAR(20),
    Title VARCHAR(30),
    ReportsTo INT,
    BirthDate DATE,
    HireDate DATE,
    Address VARCHAR(70),
    City VARCHAR(40),
    State VARCHAR(40),
    Country VARCHAR(40),
    PostalCode VARCHAR(10),
    Phone VARCHAR(24),
    Fax VARCHAR(24),
    Email VARCHAR(60)
);

CREATE TABLE IF NOT EXISTS customer (
    CustomerId INT PRIMARY KEY,
    FirstName VARCHAR(40),
    LastName VARCHAR(20),
    Company VARCHAR(80),
    Address VARCHAR(120),
    City VARCHAR(40),
    State VARCHAR(40),
    Country VARCHAR(40),
    PostalCode VARCHAR(10),
    Phone VARCHAR(24),
    Fax VARCHAR(24),
    Email VARCHAR(60),
    SupportRepId INT,
    FOREIGN KEY (SupportRepId) REFERENCES employee(EmployeeId)
);

CREATE TABLE IF NOT EXISTS invoice (
    InvoiceId INT PRIMARY KEY,
    CustomerId INT,
    InvoiceDate DATETIME,
    BillingAddress VARCHAR(70),
    BillingCity VARCHAR(40),
    BillingState VARCHAR(40),
    BillingCountry VARCHAR(40),
    BillingPostalCode VARCHAR(10),
    Total DECIMAL(10,2),
    FOREIGN KEY (CustomerId) REFERENCES customer(CustomerId)
);

CREATE TABLE IF NOT EXISTS invoice_line (
    InvoiceLineId INT PRIMARY KEY,
    InvoiceId INT,
    TrackId INT,
    UnitPrice DECIMAL(10,2),
    Quantity INT,
    FOREIGN KEY (InvoiceId) REFERENCES invoice(InvoiceId),
    FOREIGN KEY (TrackId) REFERENCES track(TrackId)
);

CREATE TABLE IF NOT EXISTS playlist (
    PlaylistId INT PRIMARY KEY,
    Name VARCHAR(120)
);

CREATE TABLE IF NOT EXISTS playlist_track (
    PlaylistId INT,
    TrackId INT,
    PRIMARY KEY (PlaylistId, TrackId),
    FOREIGN KEY (PlaylistId) REFERENCES playlist(PlaylistId),
    FOREIGN KEY (TrackId) REFERENCES track(TrackId)
);

-- ============================================================
-- 2. DATA VALIDATION
-- ============================================================

SHOW TABLES;

SELECT 'artist' AS table_name, COUNT(*) AS row_count FROM artist
UNION ALL
SELECT 'album', COUNT(*) FROM album
UNION ALL
SELECT 'genre', COUNT(*) FROM genre
UNION ALL
SELECT 'media_type', COUNT(*) FROM media_type
UNION ALL
SELECT 'track', COUNT(*) FROM track
UNION ALL
SELECT 'customer', COUNT(*) FROM customer
UNION ALL
SELECT 'employee', COUNT(*) FROM employee
UNION ALL
SELECT 'invoice', COUNT(*) FROM invoice
UNION ALL
SELECT 'invoice_line', COUNT(*) FROM invoice_line
UNION ALL
SELECT 'playlist', COUNT(*) FROM playlist
UNION ALL
SELECT 'playlist_track', COUNT(*) FROM playlist_track;

-- ============================================================
-- 3. EASY ANALYSIS
-- ============================================================

-- Q1. Longest-serving employee
SELECT
    EmployeeId,
    FirstName,
    LastName,
    Title,
    HireDate
FROM employee
ORDER BY HireDate ASC
LIMIT 1;

-- Q2. Countries with the most invoices
SELECT
    BillingCountry,
    COUNT(*) AS invoice_count
FROM invoice
GROUP BY BillingCountry
ORDER BY invoice_count DESC;

-- Q3. Top 3 invoice values
SELECT
    InvoiceId,
    Total
FROM invoice
ORDER BY Total DESC
LIMIT 3;

-- Q4. City generating the most revenue
SELECT
    BillingCity,
    ROUND(SUM(Total), 2) AS total_revenue
FROM invoice
GROUP BY BillingCity
ORDER BY total_revenue DESC
LIMIT 1;

-- Q5. Best customer by total spending
SELECT
    c.CustomerId,
    c.FirstName,
    c.LastName,
    ROUND(SUM(i.Total), 2) AS total_spending
FROM customer c
JOIN invoice i
    ON c.CustomerId = i.CustomerId
GROUP BY
    c.CustomerId,
    c.FirstName,
    c.LastName
ORDER BY total_spending DESC
LIMIT 1;

-- ============================================================
-- 4. MODERATE ANALYSIS
-- ============================================================

-- Q1. Customers who purchased Rock music
SELECT DISTINCT
    c.Email,
    c.FirstName,
    c.LastName
FROM customer c
JOIN invoice i
    ON c.CustomerId = i.CustomerId
JOIN invoice_line il
    ON i.InvoiceId = il.InvoiceId
JOIN track t
    ON il.TrackId = t.TrackId
JOIN genre g
    ON t.GenreId = g.GenreId
WHERE g.Name = 'Rock'
ORDER BY c.Email;

-- Q2. Top 10 Rock artists by number of tracks
SELECT
    a.ArtistId,
    a.Name AS artist_name,
    COUNT(t.TrackId) AS number_of_tracks
FROM track t
JOIN album al
    ON t.AlbumId = al.AlbumId
JOIN artist a
    ON al.ArtistId = a.ArtistId
JOIN genre g
    ON t.GenreId = g.GenreId
WHERE g.Name = 'Rock'
GROUP BY
    a.ArtistId,
    a.Name
ORDER BY number_of_tracks DESC
LIMIT 10;

-- Q3. Tracks longer than the average track length
SELECT
    Name,
    Milliseconds
FROM track
WHERE Milliseconds > (
    SELECT AVG(Milliseconds)
    FROM track
)
ORDER BY Milliseconds DESC;

-- ============================================================
-- 5. ADVANCED ANALYSIS
-- ============================================================

-- Q1. Customer spending on the best-selling artist
WITH best_selling_artist AS (
    SELECT
        a.ArtistId,
        a.Name AS artist_name,
        SUM(il.UnitPrice * il.Quantity) AS total_sales
    FROM invoice_line il
    JOIN track t
        ON il.TrackId = t.TrackId
    JOIN album al
        ON t.AlbumId = al.AlbumId
    JOIN artist a
        ON al.ArtistId = a.ArtistId
    GROUP BY
        a.ArtistId,
        a.Name
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT
    c.CustomerId,
    c.FirstName,
    c.LastName,
    bsa.artist_name,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS amount_spent
FROM invoice i
JOIN customer c
    ON i.CustomerId = c.CustomerId
JOIN invoice_line il
    ON i.InvoiceId = il.InvoiceId
JOIN track t
    ON il.TrackId = t.TrackId
JOIN album al
    ON t.AlbumId = al.AlbumId
JOIN best_selling_artist bsa
    ON al.ArtistId = bsa.ArtistId
GROUP BY
    c.CustomerId,
    c.FirstName,
    c.LastName,
    bsa.artist_name
ORDER BY amount_spent DESC;

-- Q2. Most popular genre for each country
WITH popular_genre AS (
    SELECT
        c.Country,
        g.Name AS genre_name,
        COUNT(il.InvoiceLineId) AS purchases,
        ROW_NUMBER() OVER (
            PARTITION BY c.Country
            ORDER BY COUNT(il.InvoiceLineId) DESC
        ) AS row_num
    FROM invoice_line il
    JOIN invoice i
        ON il.InvoiceId = i.InvoiceId
    JOIN customer c
        ON i.CustomerId = c.CustomerId
    JOIN track t
        ON il.TrackId = t.TrackId
    JOIN genre g
        ON t.GenreId = g.GenreId
    GROUP BY
        c.Country,
        g.GenreId,
        g.Name
)
SELECT
    Country,
    genre_name,
    purchases
FROM popular_genre
WHERE row_num = 1
ORDER BY Country;

-- Q3. Highest-spending customer in each country
WITH customer_spending AS (
    SELECT
        c.CustomerId,
        c.FirstName,
        c.LastName,
        c.Country,
        SUM(i.Total) AS total_spending,
        ROW_NUMBER() OVER (
            PARTITION BY c.Country
            ORDER BY SUM(i.Total) DESC
        ) AS row_num
    FROM customer c
    JOIN invoice i
        ON c.CustomerId = i.CustomerId
    GROUP BY
        c.CustomerId,
        c.FirstName,
        c.LastName,
        c.Country
)
SELECT
    Country,
    CustomerId,
    FirstName,
    LastName,
    ROUND(total_spending, 2) AS total_spending
FROM customer_spending
WHERE row_num = 1
ORDER BY Country;

-- ============================================================
-- 6. ADDITIONAL BUSINESS ANALYSIS
-- ============================================================

-- Q4. Revenue by genre
SELECT
    g.Name AS genre_name,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS revenue
FROM genre g
JOIN track t
    ON g.GenreId = t.GenreId
JOIN invoice_line il
    ON t.TrackId = il.TrackId
GROUP BY
    g.GenreId,
    g.Name
ORDER BY revenue DESC;

-- Q5. Top 10 artists by revenue
SELECT
    a.Name AS artist_name,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS revenue
FROM artist a
JOIN album al
    ON a.ArtistId = al.ArtistId
JOIN track t
    ON al.AlbumId = t.AlbumId
JOIN invoice_line il
    ON t.TrackId = il.TrackId
GROUP BY
    a.ArtistId,
    a.Name
ORDER BY revenue DESC
LIMIT 10;

-- Q6. Monthly revenue
SELECT
    DATE_FORMAT(i.InvoiceDate, '%Y-%m') AS month,
    ROUND(SUM(i.Total), 2) AS monthly_revenue
FROM invoice i
GROUP BY DATE_FORMAT(i.InvoiceDate, '%Y-%m')
ORDER BY month;

-- Q7. Customers spending more than the average customer
SELECT
    c.CustomerId,
    c.FirstName,
    c.LastName,
    ROUND(SUM(i.Total), 2) AS total_spending
FROM customer c
JOIN invoice i
    ON c.CustomerId = i.CustomerId
GROUP BY
    c.CustomerId,
    c.FirstName,
    c.LastName
HAVING SUM(i.Total) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT
            CustomerId,
            SUM(Total) AS customer_total
        FROM invoice
        GROUP BY CustomerId
    ) AS customer_spending
)
ORDER BY total_spending DESC;

-- Q8. Rank customers by total spending
WITH customer_spending AS (
    SELECT
        c.CustomerId,
        c.FirstName,
        c.LastName,
        SUM(i.Total) AS total_spending
    FROM customer c
    JOIN invoice i
        ON c.CustomerId = i.CustomerId
    GROUP BY
        c.CustomerId,
        c.FirstName,
        c.LastName
)
SELECT
    CustomerId,
    FirstName,
    LastName,
    ROUND(total_spending, 2) AS total_spending,
    DENSE_RANK() OVER (
        ORDER BY total_spending DESC
    ) AS spending_rank
FROM customer_spending
ORDER BY spending_rank;

-- Q9. Running monthly revenue
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(InvoiceDate, '%Y-%m') AS month,
        SUM(Total) AS revenue
    FROM invoice
    GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
)
SELECT
    month,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(
        SUM(revenue) OVER (
            ORDER BY month
        ), 2
    ) AS running_revenue
FROM monthly_revenue
ORDER BY month;

-- Q10. Top-selling track by quantity
SELECT
    t.TrackId,
    t.Name AS track_name,
    SUM(il.Quantity) AS units_sold
FROM track t
JOIN invoice_line il
    ON t.TrackId = il.TrackId
GROUP BY
    t.TrackId,
    t.Name
ORDER BY units_sold DESC
LIMIT 1;

-- ============================================================
-- END OF MUSIC STORE SALES ANALYSIS
-- ====================================
