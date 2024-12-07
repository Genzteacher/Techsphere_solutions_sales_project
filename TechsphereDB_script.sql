CREATE TABLE IF NOT EXISTS accounts(
	account	VARCHAR(30) PRIMARY KEY NOT NULL,
	sector VARCHAR(30),
	year_established SMALLINT,
	revenue integer,
	employees INT,
	office_location VARCHAR(30),
	subsidiary_0f VARCHAR(30),
	FOREIGN KEY(account) REFERENCES sales_pipeline(account)
);


CREATE TABLE IF NOT EXISTS products (
	product VARCHAR(20) PRIMARY KEY NOT NULL,
	series VARCHAR(5),
	sales_price INT
);

CREATE TABLE IF NOT EXISTS sales_pipeline (
	opportunity_id VARCHAR(30) PRIMARY KEY NOT NULL,
	sales_agent VARCHAR(50),
	product VARCHAR(20),
	account VARCHAR(30),
	deal_stage VARCHAR(15),
	engage_date DATE,
	close_date DATE,
	close_value INT,
	FOREIGN KEY(product) REFERENCES products(product),
	FOREIGN KEY(sales_agent) REFERENCES sales_teams(sales_agent)
);

CREATE TABLE IF NOT EXISTS sales_teams (
	sales_agent VARCHAR(30) PRIMARY KEY NOT NULL,
	manager VARCHAR(30),
	regional_office VARCHAR(20)
);

SELECT * FROM accounts


--  Query to fetch the number of wins
SELECT
	count(deal_stage) as number_of_wins
FROM
	sales_pipeline
WHERE
	deal_stage = 'Won' ;
	SELECT 
		count(opportunity_id) 
	FROM 
		sales_pipeline
	

-- query to fetch the "avg_deal_cycle_time"
SELECT 
	*,
	ROUND(COALESCE(avg(close_date-engage_date), 0), 2) as Avg_deal_cycle_time
FROM
	sales_pipeline
GROUP BY
	opportunity_id

-- Query to fetch the total number of deals

SELECT
	count(deal_stage) as total_num_of_leads
FROM
	sales_pipeline

-- QUERY TO TO GET THE QUARTERLY PERFORMANCE METRICS(TOTAL REVENUE, DEAL CLOSED, WIN_RATE)

SELECT
	EXTRACT(QUARTER FROM CLOSE_DATE) AS QUARTER,
	SUM(REVENUE) AS TOTAL_REVENUE,
	COUNT(OPPORTUNITY_ID) AS DEAL_CLOSED,
	ROUND(SUM(CASE WHEN DEAL_STAGE = 'Won' THEN 1.0 ELSE 0 END) / 
	COUNT(OPPORTUNITY_ID) * 100, 2) AS WIN_RATE
FROM
	SALES_PIPELINE AS S
LEFT JOIN 
	ACCOUNTS AS A
ON
	A.ACCOUNT = S.ACCOUNT
WHERE
	DEAL_STAGE IN ('Won', 'Lost')
GROUP BY
	EXTRACT(QUARTER FROM CLOSE_DATE)
ORDER BY
	QUARTER;

-- win_rate and total revenue per sales team

SELECT
st.sales_agent,
st.manager,

-- Total Deals
COUNT(sp.Opportunity_id) AS total_deals,

-- Win Rate
ROUND(
SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) * 100.0 /
COUNT(*)
, 2) AS win_rate,

-- Average Deal Size
ROUND(AVG(sp.close_value), 2) AS avg_deal_size, 

-- Total Revenue
SUM(sp.close_value) AS total_revenue

FROM
sales_pipeline sp
LEFT JOIN sales_teams st ON sp.sales_agent = st.sales_agent
GROUP BY
st.sales_agent, st.manager
ORDER BY
total_revenue DESC;

-- product performance metrics
SELECT
SP.Product,

-- Total Deals
COUNT(sp.Opportunity_id) AS total_deals,

-- Win Rate
ROUND(
SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) * 100.0 /
COUNT(*)
, 2) AS win_rate,

-- Average Deal Size
ROUND(AVG(sp.close_value), 2) AS avg_deal_size,

-- Total Revenue
SUM(sp.close_value) AS total_revenue,

-- Product Revenue as a Percentage of Total Revenue
ROUND(SUM(sp.close_value) * 100.0 / (SELECT SUM(close_value) FROM sales_pipeline), 2) AS revenue_percentage

FROM
sales_pipeline sp
LEFT JOIN products p ON sp.product = p.product
GROUP BY
SP.Product
ORDER BY
total_revenue DESC;


-- create view called TechsphereDB_VW to rep. the tables above

CREATE VIEW VW_TechsphereDB AS
SELECT
	sp.*,
	st.manager,
	st.regional_office,
	a.sector,
	a.revenue,
	a.year_established,
	a.employees,
	a.office_location,
	p.series,
	p.sales_price
FROM
	sales_pipeline sp
LEFT JOIN 
	products p 
ON 
	sp.product = p.product
LEFT JOIN 
	accounts a 
ON 
	sp.account = a.account
LEFT JOIN 
	sales_teams st 
ON 
	sp.sales_agent = st.sales_agent
GROUP BY
	sp.opportunity_id,
	p.product,
	a.revenue,
	st.sales_agent,
	st.manager,
	st.regional_office,
	a.year_established,
	a.employees,
	a.office_location,
	a.sector