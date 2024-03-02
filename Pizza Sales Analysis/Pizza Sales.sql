use [Pizza DB];
select * from pizza_sales;
-- KPI's
-- 1. Find The Total 
select sum(total_price) from pizza_sales;

-- 2. Find Average Order Value
select sum(total_price)/COUNT(Distinct order_id) from pizza_sales;

-- 3. Find Total Pizza Sold
select SUM(quantity) from pizza_sales;

-- 4. Total Order Placed
select COUNT(Distinct order_id) as Total_Orders from pizza_sales;

-- 5. Average Pizza Per Order; Using Cast to convert value to decimal point
select cast(cast(sum(quantity) as Decimal(10,2))/
		cast(COUNT(Distinct order_id) as Decimal(10,2)) as decimal(10,2)) As Average_Pizza
	from pizza_sales;

-- Charts
select * from pizza_sales;

-- 1. Total Number of Order on Daily Basis over the Period of time
select DATENAME(DW, order_date) as order_day, COUNT(distinct order_id) as Total_orders
	from pizza_sales
	group by DATENAME(DW, order_date);

-- 2. Total Orders Placed Monthly over the Period of TIme
select DATENAME(MONTH, order_date) as Month_Name, 
		COUNT(Distinct order_id) as Total_Orders
from pizza_sales
group by DATENAME(MONTH, order_date)
order by Total_Orders desc;

-- 3. Percentage of Sales with Pizza Category  for month January
select pizza_category, Cast(SUM(total_price) as decimal(10,2)) as Total_Sales,
	Cast(sum(total_price)*100/(select sum(total_price) from pizza_sales) 
		as decimal (10,2)) as Percentage_sale
from pizza_sales
where MONTH(order_date) = 1
group by pizza_category;

-- Percentage of Sales with Pizza Size for 1st Quarter
select pizza_size,
	cast(SUM(total_price)*100/(select SUM(total_price) from pizza_sales
			where DATEPART(QUARTER, order_date)=1)as Decimal(10,2)) as PCT
from pizza_sales
where Datepart(quarter, order_date) = 1
group by pizza_size
order by PCT;

-- Top 5 Best seller by Revenue,Quantity
select Top 5 pizza_name, 
		SUM(total_price) as Total_Revenue 
from pizza_sales
group by pizza_name
Order By Total_Revenue;

-- Bottom 5 by Quantity
select Top 5 pizza_name, 
		SUM(quantity) as Total_Quantity
from pizza_sales
group by pizza_name
Order By Total_Quantity ASC;