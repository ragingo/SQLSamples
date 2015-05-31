use sample
go

/*
create table image_data(
	id int not null primary key identity,
	name varchar(100),
	data varbinary(max)
)

go

insert into image_data(name, data)
select
	'test1',
	(select * from openrowset(bulk N'C:\Users\Public\Pictures\Sample Pictures\Koala.bmp', SINGLE_BLOB) as bin)
go

*/


with
	Param as (
		select name, convert(varchar(max), data, 2) as data from image_data where name = 'test1'
	),
	BITMAPFILEHEADER as (
		select
			(char(convert(binary(1), substring(p.data, 1, 2), 2)) +
			 char(convert(binary(1), substring(p.data, 3, 2), 2))
			) as bfType,
			cast(substring(p.data, 5, 8) as int) as bfSize, -- これはだめ。LEだからやっぱり関数使いたい
			cast(substring(p.data, 13, 4) as int) as bfReserved1,
			cast(substring(p.data, 17, 4) as int) as bfReserved2,
			cast(substring(p.data, 21, 8) as int) as bfOffBits
		from
			Param as p
	),
	BITMAPINFOHEADER as (
		select
			cast(substring(p.data, 29, 8) as int) as biSize,
			cast(substring(p.data, 37, 8) as int) as biWidth,
			cast(substring(p.data, 45, 8) as int) as biHeight,
			cast(substring(p.data, 53, 4) as int) as biPlanes,
			substring(p.data, 53, 4) as biPlanes_a,
			1 as a
		from
			Param as p
	),
	BitmapInfo as (
		select
			*
		from
			BITMAPFILEHEADER,
			BITMAPINFOHEADER
	)
select
	*
from
	BitmapInfo