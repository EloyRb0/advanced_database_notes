--Analytic Functions: Databases for Developers--
--I included all the queries run in the tutorial/activity, so it may not run properly on its own--
drop table bricks cascade constraints;
create table bricks (
  brick_id integer,
  colour   varchar2(10),
  shape    varchar2(10),
  weight   integer
);

insert into bricks values ( 1, 'blue', 'cube', 1 );
insert into bricks values ( 2, 'blue', 'pyramid', 2 );
insert into bricks values ( 3, 'red', 'cube', 1 );
insert into bricks values ( 4, 'red', 'cube', 2 );
insert into bricks values ( 5, 'red', 'pyramid', 3 );
insert into bricks values ( 6, 'green', 'pyramid', 1 );

commit;


select count(*) from bricks;


select count(*) over () from bricks;


select b.*,
       count(*) over () total_count
from   bricks b;


select colour, count(*), sum ( weight )
from   bricks
group  by colour;


select b.*,
       count(*) over (
         partition by colour
       ) bricks_per_colour,
       sum ( weight ) over (
         partition by colour
       ) weight_per_colour
from   bricks b;


select b.*,
       count(*) over (
         partition /* TODO */
       ) bricks_per_shape,
       median ( weight ) over (
         partition /* TODO */
       ) median_weight_per_shape
from   bricks b
order  by shape, weight, brick_id;


select b.*,
       count(*) over (
         order by brick_id
       ) running_total,
       sum ( weight ) over (
         order by brick_id
       ) running_weight
from   bricks b;


select b.brick_id, b.weight,
       round ( avg ( weight ) over (
         order /* TODO */
       ), 2 ) running_average_weight
from   bricks b
order  by brick_id;


select b.*,
       count(*) over (
         partition by colour
         order by brick_id
       ) running_total,
       sum ( weight ) over (
         partition by colour
         order by brick_id
       ) running_weight
from   bricks b;


select b.*,
       count(*) over (
         order by weight
       ) running_total,
       sum ( weight ) over (
         order by weight
       ) running_weight
from   bricks b
order  by weight;


select b.*,
       count(*) over (
         order by weight
         rows between unbounded preceding and current row
       ) running_total,
       sum ( weight ) over (
         order by weight
         rows between unbounded preceding and current row
       ) running_weight
from   bricks b
order  by weight;


select b.*,
       count(*) over (
         order by weight, brick_id
         rows between unbounded preceding and current row
       ) running_total,
       sum ( weight ) over (
         order by weight, brick_id
         rows between unbounded preceding and current row
       ) running_weight
from   bricks b
order  by weight, brick_id;


select b.*,
       sum ( weight ) over (
         order by weight
         rows between 1 preceding and current row
       ) running_row_weight,
       sum ( weight ) over (
         order by weight
         range between 1 preceding and current row
       ) running_value_weight
from   bricks b
order  by weight, brick_id;


select b.*,
       sum ( weight ) over (
         order by weight
         rows between 1 preceding and 1 following
       ) sliding_row_window,
       sum ( weight ) over (
         order by weight
         range between 1 preceding and 1 following
       ) sliding_value_window
from   bricks b
order  by weight;


select b.*,
       count(*) over (
         order by weight, brick_id
         rows between unbounded preceding and current row
       ) running_total,
       sum ( weight ) over (
         order by weight, brick_id
         rows between unbounded preceding and current row
       ) running_weight
from   bricks b
order  by weight, brick_id;


select b.*,
       sum ( weight ) over (
         order by weight
         rows between 1 preceding and current row
       ) running_row_weight,
       sum ( weight ) over (
         order by weight
         range between 1 preceding and current row
       ) running_value_weight
from   bricks b
order  by weight, brick_id;



select b.*,
       sum ( weight ) over (
         order by weight
         rows between 1 preceding and 1 following
       ) sliding_row_window,
       sum ( weight ) over (
         order by weight
         range between 1 preceding and 1 following
       ) sliding_value_window
from   bricks b
order  by weight;


select b.*,
       count (*) over (
         order by weight
         range between 2 preceding and 1 preceding
       ) count_weight_2_lower_than_current,
       count (*) over (
         order by weight
         range between 1 following and 2 following
       ) count_weight_2_greater_than_current
from   bricks b
order  by weight;


select b.*,
       min ( colour ) over (
         order by brick_id
         rows /* TODO */
       ) first_colour_two_prev,
       count (*) over (
         order by weight
         range /* TODO */
       ) count_values_this_and_next
from   bricks b
order  by weight;


select colour from bricks
group  by colour
having count(*) >= 2;


select colour from bricks
where  count(*) over ( partition by colour ) >= 2;


select * from (
  select b.*,
         count (*) over ( partition by colour ) colour_count
  from   bricks b
)
where  colour_count >= 2;


with totals as (
  select b.*,
         sum ( weight ) over (
           /* TODO */
         ) weight_per_shape,
         sum ( weight ) over (
           /* TODO */
         ) running_weight_by_id
  from   bricks b
)
select * from totals
where  /* TODO */
order  by brick_id


select brick_id, weight,
       row_number() over ( order by weight ) rn,
       rank() over ( order by weight ) rk,
       dense_rank() over ( order by weight ) dr
from   bricks;


select b.*,
       lag ( shape ) over ( order by brick_id ) prev_shape,
       lead ( shape ) over ( order by brick_id ) next_shape
from   bricks b;


select b.*,
       first_value ( weight ) over (
         order by brick_id
       ) first_weight_by_id,
       last_value ( weight ) over (
         order by brick_id
       ) last_weight_by_id
from   bricks b;


select b.*,
       first_value ( weight ) over (
         order by brick_id
       ) first_weight_by_id,
       last_value ( weight ) over (
         order by brick_id
         range between current row and unbounded following
       ) last_weight_by_id
from   bricks b;

--Top Three Salaries--

WITH ranked_salary AS (
  SELECT name, salary, department_id, DENSE_RANK() OVER (
      PARTITION BY department_id ORDER BY salary DESC) AS ranking
  FROM employee
)
SELECT 
  d.department_name, s.name, s.salary FROM ranked_salary AS s
INNER JOIN department AS d ON s.department_id = d.department_id
WHERE s.ranking <= 3
ORDER BY d.department_name ASC, s.salary DESC, s.name ASC;
