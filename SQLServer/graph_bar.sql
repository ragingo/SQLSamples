
with
	sequence(x) as (
		select 1
		union all
		select
			x + 1
		from
			sequence
		where
			x < 12*2
	),
	data as (
		select
			left(convert(char(7), dateadd(month, x-1, getdate()), 111), 7) as month,
			abs(cast(checksum(newid()) as bigint)) % 9000 + 1000 as gas
		from
			sequence
	),
	data2 as (
		select
			month,
			gas,
			replicate(
				case
					when gas between    0 and 3999 then N'Å†'
					when gas between 4000 and 8999 then N'Å°'
					when gas >= 9000 then N'Åô'
				end,
				gas / 1000) as graph
		from
			data
	)
select
	month,
	gas,
	graph
from
	data2
option (MAXRECURSION 0)

go
