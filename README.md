# Music Store Analysis

An end-to-end data analysis project using SQL and Power BI to analyze music store sales, customer activity, track performance, and revenue trends.

## 📌 Project Overview

This project analyzes a music store database containing customers, invoices, tracks, albums, artists, genres, playlists, and related sales data.

SQL was used to query and analyze the relational database, while Power BI was used to create an interactive dashboard for visualizing key business metrics and sales insights.

## 🛠️ Tools & Technologies

- MySQL
- SQL
- Power BI
- DAX
- CSV

## 🗄️ Database Schema

The project uses the following tables:

- `album`
- `artist`
- `customer`
- `employee`
- `genre`
- `invoice`
- `invoice_line`
- `media_type`
- `playlist`
- `playlist_track`
- `track`

The database schema is available in:

`MusicDatabaseSchema.png`

## 🔍 SQL Analysis

SQL queries were used to analyze:

- Total revenue
- Total orders
- Total customers
- Track sales
- Revenue by country
- Revenue by genre
- Top tracks by revenue
- Artist and track performance
- Monthly revenue trends
- Customer and sales information

All SQL queries are available in:

`music_store_analysis.sql`

## 📊 Power BI Dashboard

An interactive Power BI dashboard was created to present the main business metrics and sales insights.

### Key KPIs

| Metric | Value |
|---|---:|
| Total Revenue | 4.71K |
| Total Orders | 614 |
| Total Customers | 59 |
| Total Tracks Sold | 592 |
| Total Artists | 275 |
| Total Genres | 25 |

### Dashboard Visuals

- Monthly Revenue Trend
- Revenue by Genre
- Top 10 Tracks by Revenue
- Revenue by Country
- Track Revenue by Name

Dashboard screenshots are available in:

- `dashboard_page1.png`
- `dashboard_page2.png`

The Power BI project file is available as:

`music_store_analysis.pbix`

## 📈 Key Insights

- The USA generated the highest revenue among the countries shown in the dashboard.
- Rock generated the highest revenue among the genres shown.
- The dashboard identifies the top 10 tracks based on revenue.
- Monthly revenue varies across the year, allowing sales trends to be compared over time.

## 📁 Project Structure

```text
Music-Store-Analysis/
│
├── Data/
│   ├── album.csv
│   ├── artist.csv
│   ├── customer.csv
│   ├── employee.csv
│   ├── genre.csv
│   ├── invoice.csv
│   ├── invoice_line.csv
│   ├── media_type.csv
│   ├── playlist.csv
│   ├── playlist_track.csv
│   └── track.csv
│
├── MusicDatabaseSchema.png
├── dashboard_page1.png
├── dashboard_page2.png
├── music_store_analysis.sql
├── music_store_analysis.pbix
└── README.md
