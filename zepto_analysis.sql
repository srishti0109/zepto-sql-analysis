SELECT * FROM firstproject.sale;

alter table sale
add column sku_id int auto_increment primary key;

alter table sale
modify column sku_id int first;

select * from sale
limit 10;

-- check null values
select * from sale
where Category is null
or
name is null
or
mrp is null
or
discountPercent is null
or
availableQuantity is null
or
discountedSellingPrice is null
or
weightInGms is null
or
outOfStock is null
or
quantity is null;

-- different product categories
select distinct Category
from sale
order by Category;

-- product in stock vs out of stock
select outOfStock, count(sku_id)
from sale
group by outOfStock;

-- product names present multiple times
select name, count(sku_id) as "Number of SKUs"
from sale
group by name
having count(sku_id) > 1
order by count(sku_id) desc;

-- data cleaning

-- check product with price = 0
select * from sale
where mrp=0 or discountedSellingPrice =0;

delete from sale
where mrp=0;

-- disabling safe update mode to delete rows with mrp 0 
set SQL_SAFE_UPDATES = 0;

-- checking current column datatype
describe sale;

-- changing column datatype from int to decimal
alter table sale
modify column mrp decimal (10,2),
modify column discountedSellingPrice decimal (10,2); 

-- previewing values before actual update
select mrp,
mrp/100.0,
discountedSellingPrice,
discountedSellingPrice/100.0
from sale;

-- converting prices from paise to rupees
-- WARING: don't run this query again never otherwise it will again update the data and make mrp 0 
update sale
set mrp = mrp / 100.0,
discountedSellingPrice = discountedSellingPrice / 100.0;

-- checking updated values after conversion
select mrp, discountedSellingPrice
from sale;

-- some business insights questions
-- Q1) Find the top 10 best-value product based on the discount percentagae.
select distinct name, mrp, discountPercent
from sale
order by discountPercent desc
limit 10;

-- Q2) Calculate Estimated Revenue for each category
select Category,
sum(discountedSellingPrice * availableQuantity) as total_revenue
from sale
group by Category
order by total_revenue;

-- Q3) Find all products where mrp is greater than rs500 and discount is less than 10%.
select distinct name, mrp, discountPercent
from sale
where mrp > 500 and discountPercent < 10
order by mrp desc, discountPercent desc;

-- Q4) Identify the top 5 categories offering the highest avaerage discount percentage. 
select Category,
round(avg(discountPercent),2) as avg_discount
from sale
group by Category
order by avg_discount desc
limit 5;

-- Q5) Find the price per gram for products above 100g and sort by best value. 
select distinct name, weightInGms, discountedSellingPrice,
round(discountedSellingPrice / weightInGms,2) as price_per_gram
from sale
where weightInGms >= 100
order by price_per_gram;

-- Q6) Group the products into categories like low, medium, bulk. 
select distinct name, weightInGms,
case when weightInGms < 1000 then 'Low'
     when weightInGms < 5000 then 'Medium'
     else 'Bulk'
end as weight_category
from sale;

-- Q7) What is the total inventory weight per category
select Category,
sum(weightInGms * availableQuantity) as total_weight
from sale
group by Category
order by total_weight;