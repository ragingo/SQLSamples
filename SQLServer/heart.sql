with
	Seq(x) as (
		select convert(float, -1.57)
		union all
		select
			convert(float, 0.01+x)
		from
			Seq
		where
			x <= 1.57
	),
	HeartCore(x, y) as (
		select
			round((x + 1.59) * 100 + 1, 0),
			(sqrt(cos(x)) * cos(200*x) + sqrt(abs(x)) - 0.7) * power(4-x*x, 0.01)
		from
			Seq
	),
	Heart(x, y) as (
		select
			x,
			round(y*100, 0) + 200
		from
			HeartCore
	)
select
	x,
	y,
	replicate(' ', y) + '*'
from
	Heart
where
	convert(int, x) % 2 = 0

option (MAXRECURSION 0)

