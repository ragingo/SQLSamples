use sample
go


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
	),
	parameters as (
		select 20 as amp, 10 as freq, 50 as y
	),
	data as (
		select
			seq.x as num,
			round(param.amp * sin((seq.x-1)/180.0 * pi() * param.freq), 0) + param.y as pos
		from
			sequence seq,
			parameters param
	)
select
	replicate(' ', d.pos) + '*' + replicate(' ', d.pos) as plot
from
	data d

option (MAXRECURSION 0)
