use laptops_dataset;

-- head, tail and sample
-- getting overview of data

-- top 5 sample
select * from laptop
order by id 
limit 5;

-- bottom 5 sample
select * from laptop
order by id desc
limit 5;

-- random 5 smaple
select * from laptop
order by rand()
limit 5;

-- for numerical column 8 number summary
-- count, mean, max, min, std. deviation, q1, q2, q3
-- data is skewed since there is large difference between average and median
with stats_summary as(
select price, count(price) over(),
min(price) over() as minimum_price,
max(price) over() as maximum_price,
avg(price) over() as average_price,
std(price) over() standard_deviation,
percent_rank() over(order by price)  as percentile
from laptop),

cte as(
select minimum_price, maximum_price, average_price,standard_deviation 
from stats_summary
limit 1),

cte2 as(
select price as first_quartile from stats_summary 
where percentile >= 0.25
limit 1),

cte3 as(select price as median from stats_summary 
where percentile >= 0.50
limit 1),

cte4 as(select price as third_quartile from stats_summary 
where percentile >= 0.75
limit 1)

select minimum_price, maximum_price, average_price, standard_deviation, first_quartile, median, third_quartile
from cte, cte2, cte3, cte4;

-- check missing value for all column 
-- already done it while doing data cleaning

-- outlier detection
-- no need to do it here

-- plotting histogram
select price_bucket, repeat('*',count(*)/5) from (select price,
case when price between 0 and 25000 then '0-25k'
when price between 25001 and 50000 then '25k-50k'
when price between 50001 and 75000 then '50k-75k'
when price between 75001 and 100000 then '75k-100k'
when price > 100000 then '>100k'
end as 'price_bucket'
from laptop)t
group by price_bucket;

-- counting total laptop for every company
select Company, count(*) as total_laptop
from laptop
group by company;

-- percent of touchscreen laptop
select 100*(count(*)/(select count(*) from laptop)) as percentage
from laptop 
where touchscreen = 1
order by percentage desc;

-- laptops percentage by cpu brand
select cpu_brand,  100*(count(*)/(select count(*) from laptop)) as percentage
from laptop
group by cpu_brand
order by percentage desc;

-- laptops percentage by Gpu brand
select gpu_brand,  100*(count(*)/(select count(*) from laptop)) as percentage
from laptop
group by gpu_brand
order by percentage desc;

-- laptops percentage by type
select TypeName,  100*(count(*)/(select count(*) from laptop)) as percentage
from laptop
group by TypeName
order by percentage desc;

-- laptops percentage by screen size
select inches as screen_size,  100*(count(*)/(select count(*) from laptop)) as percentage
from laptop
group by inches
order by percentage desc;

-- laptops percentage by cpu version
select cpu_name,  100*(count(*)/(select count(*) from laptop)) percentage
from laptop
group by cpu_name
order by percentage desc;

-- laptops percentage by memory_type
select memory_type,  100*(count(*)/(select count(*) from laptop)) percentage
from laptop
group by memory_type
order by percentage desc;

-- laptops percentage by Opsys
select Opsys, 100*(count(*)/(select count(*) from laptop)) percentage
from laptop
group by Opsys
order by percentage desc;

-- average weight of laptop by brand
select company, avg(weight) as avg_wt
from laptop
group by company
order by avg_wt desc;

-- average price of laptop by brand
select company, avg(price) as avg_price
from laptop
group by company
order by avg_price desc;

-- average price of laptop by company, average cpu speed, average price
select company, avg(cpu_speed) as avg_cpu_speed, avg(price) as avg_price
from laptop
group by company
order by avg_price desc;

-- brands by touchscreen laptop
select company,
sum(case when touchscreen = 1 then 1 else 0 end) as 'touchscreen_yes',
sum(case when touchscreen = 0 then 1 else 0 end) as 'touchscreen_no'
from laptop
group by company;

-- laptop count by cpu_brand
select company,
sum(case when cpu_brand = 'Intel' then 1 else 0 end) as 'intel',
sum(case when cpu_brand = 'AMD' then 1 else 0 end) as 'amd',
sum(case when cpu_brand = 'Samsung' then 1 else 0 end) as 'samsung'
from laptop
group by company;

-- categorical numerical bivariate analysis
select company,
min(price),max(price),avg(price),std(price)
from laptop
group by company;

-- missing value treatment

-- updating null price with mean
update laptop
set price = (select avg(price) from laptops)
where price is null;

-- update null price with mean price of that particular company
update laptop l1
set price = (select avg(price) from laptops l2 where l2.company = l1.company)
where price is null;

-- feature engineering

-- adding new column ppi
alter table laptop add column ppi integer;

-- calculating ppi for every laptop
update laptop
set ppi = round(sqrt(screen_width * screen_width + screen_height * screen_height) / Inches);

-- categorizing laptop based upon screen size
alter table laptop add column screen_size varchar(255) after inches;

update laptop
set screen_size = 
case 
	when inches < 14.0 then 'small'
    when inches >= 14.0 and inches < 17.0 then 'medium'
	else 'large'
end;

-- one hot encoding
select gpu_brand,
case when gpu_brand = 'Intel' then 1 else 0 end as 'intel',
case when gpu_brand = 'AMD' then 1 else 0 end as 'amd',
case when gpu_brand = 'nvidia' then 1 else 0 end as 'nvidia',
case when gpu_brand = 'arm' then 1 else 0 end as 'arm'
from laptop;

select * from laptop;


