--Union, Minus, and Intersect: Databases for Developers--
--I included all the queries run in the tutorial/activity, so it may not run properly on its own--

create table my_brick_collection (
colour varchar2(10),
shape  varchar2(10),
weight integer
);

drop table your_brick_collation cascade constraints;
create table your_brick_collection (
  height integer,
  width  integer,
  depth  integer,
  colour varchar2(10),
  shape  varchar2(10)
);

insert into my_brick_collection values ( 'red', 'cube', 10 );
insert into my_brick_collection values ( 'blue', 'cuboid', 8 );
insert into my_brick_collection values ( 'green', 'pyramid', 20 );
insert into my_brick_collection values ( 'green', 'pyramid', 20 );
insert into my_brick_collection values ( null, 'cuboid', 20 );

insert into your_brick_collection values ( 2, 2, 2, 'red', 'cube' );
insert into your_brick_collection values ( 2, 2, 2, 'blue', 'cube' );
insert into your_brick_collection values ( 2, 2, 8, null, 'cuboid' );

commit;


select * from my_brick_collection;

select * from your_brick_collection;



select colour, shape from my_brick_collection
union
select colour, shape from your_brick_collection;

select distinct * from my_brick_collection;
select distinct shape from your_brick_collection;

select colour, shape from my_brick_collection
union all
select colour, shape from your_brick_collection;

select distinct * from (
  select colour, shape from my_brick_collection
  union all
  select colour, shape from your_brick_collection
);

--TRY IT-------------------------------
select colour from my_brick_collection
UNION
select colour from your_brick_collection
order by colour;

select shape from my_brick_collection
UNION ALL
select shape from your_brick_collection
order by shape;
---------------------------------------

select colour, shape from your_brick_collection ybc
where  not exists (
  select null from my_brick_collection mbc
  where  ybc.colour = mbc.colour
  and    ybc.shape = mbc.shape
);


select colour, shape from your_brick_collection ybc
where  not exists (
  select null from my_brick_collection mbc
  where  ( ybc.colour = mbc.colour or
    ( ybc.colour is null and mbc.colour is null )
  )
  and    ( ybc.shape = mbc.shape or
    ( ybc.shape is null and mbc.shape is null )
  )
);

select colour, shape from your_brick_collection
minus
select colour, shape from my_brick_collection;


select colour, shape from my_brick_collection
minus
select colour, shape from your_brick_collection

select colour, shape from my_brick_collection mbc
where  not exists (
  select null from your_brick_collection ybc
  where  ( ybc.colour = mbc.colour or ( ybc.colour is null and mbc.colour is null ) )
  and    ybc.shape = mbc.shape
);

select colour, shape from your_brick_collection ybc
where  exists (
  select null from my_brick_collection mbc
  where  ( ybc.colour = mbc.colour or ( ybc.colour is null and mbc.colour is null ) )
  and    ybc.shape = mbc.shape
);

select colour, shape from your_brick_collection
intersect
select colour, shape from my_brick_collection;

--------TRY IT-------------------------------
select shape from my_brick_collection
minus
select shape from your_brick_collection;

select colour from my_brick_collection
INTERSECT
select colour from your_brick_collection
order  by colour;

----------------------------------------------

select colour, shape from your_brick_collection
minus
select colour, shape from my_brick_collection
union all
select colour, shape from my_brick_collection
minus
select colour, shape from your_brick_collection;


select * from (
  select colour, shape from your_brick_collection
  minus
  select colour, shape from my_brick_collection
) union all (
  select colour, shape from my_brick_collection
  minus
  select colour, shape from your_brick_collection
);


select * from (
  select colour, shape from your_brick_collection
  union all
  select colour, shape from my_brick_collection
) minus (
  select colour, shape from my_brick_collection
  intersect
  select colour, shape from your_brick_collection
);


insert into your_brick_collection values ( 4, 4, 4, 'red', 'cube' );

select * from (
  select colour, shape from your_brick_collection
  minus
  select colour, shape from my_brick_collection
) union all (
  select colour, shape from my_brick_collection
  minus
  select colour, shape from your_brick_collection
);


select colour, shape, sum ( your_bricks ), sum ( my_bricks )
from (
  select colour, shape, 1 your_bricks, 0 my_bricks
  from   your_brick_collection
  union all
  select colour, shape, 0 your_bricks, 1 my_bricks
  from   my_brick_collection
)
group  by colour, shape
having sum ( your_bricks ) <> sum ( my_bricks );


select colour, shape,
       case
         when sum ( your_bricks ) < sum ( my_bricks ) then 'ME'
         when sum ( your_bricks ) > sum ( my_bricks ) then 'YOU'
         else 'EQUAL'
       end who_has_extra,
       abs ( sum ( your_bricks ) - sum ( my_bricks ) ) how_many
from (
  select colour, shape, 1 your_bricks, 0 my_bricks
  from   your_brick_collection
  union all
  select colour, shape, 0 your_bricks, 1 my_bricks
  from   my_brick_collection
)
group  by colour, shape;
