
with
	sequence(x) as (
		select 1
		union all
		select
			x + 1
		from
			sequence
		where
			x < 10000
	)
select
	*
from
	sequence

option (MAXRECURSION 0)
