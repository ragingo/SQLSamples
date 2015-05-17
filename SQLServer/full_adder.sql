use sample
go

with
	input as (
		select 0 as a, 0 as b, 1 as x
		union all
		select 0 as a, 1 as b, 0 as x
		union all
		select 0 as a, 1 as b, 1 as x
		union all
		select 1 as a, 0 as b, 0 as x
		union all
		select 1 as a, 0 as b, 1 as x
		union all
		select 1 as a, 1 as b, 0 as x
		union all
		select 1 as a, 1 as b, 1 as x
	),
	half_adder as (
		select distinct
			a,
			b,
			(a & b) as c,
			(a ^ b) as s
		from
			input
	),
	full_adder as (
		select
			h1.a,
			h1.b,
			h2.b as x,
			(h1.c | h2.c) as c,
			h2.s
		from
			half_adder h1
			inner join half_adder h2 on h1.s = h2.a
			
	)
select
	*
from
	full_adder
order by
	a,b,x,c,s
