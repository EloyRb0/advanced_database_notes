--Lesson 10--
SELECT MAX(years_employed) as Max_years_employed
FROM employees;
SELECT role, AVG(years_employed) as Average_years_employed
FROM employees
GROUP BY role;
SELECT building, SUM(years_employed) as Total_years_employed
FROM employees
GROUP BY building;

--Lesson 11--
SELECT role, COUNT(*) as Number_of_artists
FROM employees
WHERE role = "Artist";
SELECT role, COUNT(*)
FROM employees
GROUP BY role;
SELECT role, SUM(years_employed)
FROM employees
GROUP BY role
HAVING role = "Engineer";

--FreeSQL Tutorial--
drop table bricks cascade constraints;
create table bricks (
  colour varchar2(10),
  shape  varchar2(10),
  weight integer
);

insert into bricks values ( 'red', 'cube', 1 );
insert into bricks values ( 'red', 'pyramid', 2 );
insert into bricks values ( 'red', 'cuboid', 1 );
insert into bricks values ( 'blue', 'cube', 1 );
insert into bricks values ( 'blue', 'pyramid', 2 );
insert into bricks values ( 'green', 'cube', 3 );
commit;

select * from bricks;
select count (*) from bricks;
select count ( colour ) from bricks;

select sum ( weight ), min ( weight ), max ( weight ),
       avg ( weight ), stddev ( weight ),
       median ( weight ), variance ( weight ),
       stats_mode ( weight )
from   bricks;

select count ( distinct colour ) number_of_different_colours
from   bricks;

select count ( all colour ) total_number_of_rows,
       count ( distinct colour ) number_of_different_colours,
       count ( unique colour ) number_of_unique_colours 
from   bricks;

select sum ( weight ) total_weight, 
       sum ( distinct weight ) sum_of_unique_weights,
       avg ( weight ) overall_mean, 
       avg ( distinct weight ) mean_of_unique_weights
from   bricks;

select count(shape) number_of_shapes,
       stddev(distinct weight) distinct_weight_stddev
from   bricks;

select colour, count (*)
from   bricks
group  by colour;

select count (*)
from   bricks
group  by colour;

select colour, shape, count (*)
from   bricks
group  by colour, shape;

select shape, weight, count (*)
from   bricks
group  by shape, weight;

select shape, sum(weight) shape_weight
from   bricks
group  by shape;

select colour, count (*)
from   bricks
where  weight > 1
group  by colour;

select colour, count (*)
from   bricks
group  by colour
having count (*) > 1;

select colour, count (*)
from   bricks
having count (*) > 1
group  by colour;

select colour, count (*)
from   bricks
having sum ( weight ) > 1
group  by colour;

select shape, sum ( weight )
from   bricks
group  by shape;

select colour, shape, count (*)
from   bricks
group  by rollup ( colour, shape );

select colour, shape, count (*)
from   bricks
group  by colour, rollup ( shape );

select colour, shape, count (*)
from   bricks
group  by cube ( colour, shape );