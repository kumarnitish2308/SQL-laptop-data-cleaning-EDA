use laptops_dataset;
select * from laptop;

alter table laptopdata
rename to laptop;

-- creating a backup table
create table laptop_backup like laptop;

-- inserting data into backup table
insert into laptop_backup
select * from laptop;

-- checking memory consumption of data
select data_length/1024 as 'data_size(kb)' from information_schema.tables
where table_schema = 'laptops_dataset' and table_name = 'laptop';

-- drop non-important column
alter table laptop
drop column `Unnamed: 0`; -- used tilde symbol because there is space in column name

set sql_safe_updates = 0;
set sql_safe_updates = 1;

-- dropping rows where all values is null
delete from laptop
where company is null and typename is null and inches is null
and screenresolution is null and cpu is null and ram is null
and memory is null and gpu is null and opsys is null and
weight is null and price is null;

-- 30 rows dropped
select count(*) from laptop;

-- adding primary key column
alter table laptop
add column id int auto_increment primary key first;

-- drop duplicates
delete from laptop 
where id not in (
select min_id from (select min(id) as min_id from laptop 
group by company, typename, inches, screenresolution, cpu, ram, memory, gpu, opsys, weight, price
) as t
);

-- checking all columns for null or missing value
-- no null value found for any column

select company from laptop where company is null;
select TypeName from laptop where TypeName is null;
select Inches from laptop where Inches is null;
select ScreenResolution from laptop where ScreenResolution is null;
select cpu from laptop where cpu is null;
select Ram from laptop where Ram is null;
select Memory from laptop where Memory is null;
select Gpu from laptop where Gpu is null;
select OpSys from laptop where OpSys is null;
select weight from laptop where weight is null;
select price from laptop where price is null;							

-- checking and changing the column to proper data type

-- checking datatypes of column
describe laptop;

-- convert inches column to decimal
delete from laptop where inches = '?';

alter table laptop
modify column Inches decimal(10,1);

-- cleaning and changing data type of Ram column
update laptop l1
join (select id, replace(Ram, 'GB', '') as new_ram from laptop) as l2 on l1.id = l2.id
set l1.ram = l2.new_ram;

update laptop 
set ram =  replace(Ram, 'GB', '');

alter table laptop modify column Ram int;

-- cleaning and changing data type of weight column
update laptop l1
join (select id, replace(Weight, 'kg', '') as new_wt from laptop) as l2 on l1.id = l2.id
set l1.Weight = l2.new_wt;

delete from laptop where weight = '?';
alter table laptop modify column Weight decimal(10,2);
 
-- formatting price column and changing its data type
update laptop l1
join (select id, round(Price) as new_price from laptop) as l2 on l1.id = l2.id
set l1.Price = l2.new_price;

alter table laptop modify column Price int;

-- cleaning and modifying OpSys column
-- making a column with the name operating system
update laptop
set opsys = case
				when Opsys like '%linux%' then 'Linux'
				when opsys like '%windows%' then 'Windows'
				when opsys like '%mac%' then 'Mac'
				when opsys = 'No OS' then 'N/A'
			else 'other' end ;

-- cleaning and modifying Gpu column
-- creating 2 column one Gpu brand and other Gpu version from Gpu column
alter table laptop
add column gpu_brand varchar(255) after gpu,
add column gpu_name varchar(255) after gpu_brand;

-- adding data into newly created column
-- filling data into gpu_brand column
update laptop l1
join (select id, substring_index(Gpu, ' ', 1) as new_gpu_brand from laptop ) as l2 on l1.id = l2.id
set gpu_brand = new_gpu_brand;

-- filling data into gpu_name column
update laptop l1
join (select id, replace(Gpu, gpu_brand,'') as new_gpu_name from laptop ) as l2 on l1.id = l2.id
set gpu_name = new_gpu_name;

-- dropping gpu column
alter table laptop drop column gpu;

-- cleaning and modifying Cpu column
-- creating 3 column one Cpu brand and other Cpu name and Cpu speed from Cpu column
alter table laptop
add column cpu_brand varchar(255) after cpu,
add column cpu_name varchar(255) after cpu_brand,
add column cpu_speed varchar(255) after cpu_name;
alter table laptop modify column cpu_speed decimal(10,2);

-- filling data into cpu brand column
update laptop l1
join (select id, substring_index(Cpu, ' ',1) as new_cpu_brand from laptop ) as l2 on l1.id = l2.id
set cpu_brand = new_cpu_brand;

-- filling data into cpu speed column
update laptop l1
join (select id, replace(substring_index(cpu,' ',-1), 'GHz', '') as new_cpu_speed from laptop ) as l2 on l1.id = l2.id
set cpu_speed = new_cpu_speed;

-- filling data into cpu name column
update laptop
set cpu_name = replace(replace(Cpu, cpu_brand, ''), substring_index(replace(Cpu, cpu_brand, ''), ' ', -1), '');

-- modifying data inside the cpu_name column
update laptop 
set cpu_name = substring_index(trim(cpu_name), ' ', 2);

-- dropping column Cpu
alter table laptop 
drop column cpu;


-- creating 3 column with name resolution width, resolution height and touchscreen 
alter table laptop add column screen_width int after ScreenResolution;
alter table laptop add column screen_height int after screen_width;
alter table laptop add column touchScreen int after screen_height;

-- filling screen height column
update laptop
set screen_height = substring_index(substring_index(screenResolution, ' ', -1), 'x', 1);

-- filling screen width column
update laptop
set screen_width = substring_index(substring_index(screenResolution, ' ', -1), 'x', -1);

-- filling touchScreen column
update laptop
set touchScreen = case when screenResolution like '%Touch%' then 1 else 0 end;

-- dropping column screenresolution
alter table laptop drop column screenresolution;

-- adding 3 new column from memory column
alter table laptop add column memory_type varchar(255) after Memory;
alter table laptop add column primary_storage int after memory_type;
alter table laptop add column secondary_storage int after primary_storage;

-- filling data into memory_type column
update laptop
set memory_type = case
    when Memory like '%SSD%' and Memory like '%HDD%' then 'Hybrid'
    when Memory like '%SSD%' then 'SSD'
    when Memory like '%HDD%' then 'HDD'
    when Memory like '%Flash Storage%' then 'Flash Storage'
    when Memory like '%Hybrid%' then 'Hybrid'
    when Memory like '%Flash Storage%' and Memory like '%HDD%' then 'Hybrid'
    else NULL
end;
-- filling data into primary storage and secondary storage column
update laptop
set primary_storage = regexp_substr(substring_index(Memory,'+',1),'[0-9]+'),
secondary_storage = case when Memory like '%+%' then regexp_substr(substring_index(Memory,'+',-1),'[0-9]+') else 0 end;

-- multiplying storage with 1024 where storage is either 1 TB or 2TB
update laptop
set primary_storage = case when primary_storage <= 2 then primary_storage*1024 else primary_storage end,
secondary_storage = case when secondary_storage <= 2 then secondary_storage*1024 else secondary_storage end;

-- dropping memory column
alter table laptop drop column Memory;

-- gpu name column is not of our use
alter table laptop drop column gpu_name;

select * from laptop;