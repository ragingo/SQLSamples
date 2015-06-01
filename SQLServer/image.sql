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
		select name, convert(varchar(max), data, 2) as data, data as rawdata from image_data where name = 'test1'
	),
	BITMAPFILEHEADER as (
		select
			convert(char(2), convert(binary(2), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 1, 2), 2)) as bfType,
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata,  3, 4), 2))) )as bfSize,
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata,  7, 2), 2))) )as bfReserved1,
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata,  9, 2), 2))) )as bfReserved2,
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 11, 4), 2))) )as bfOffBits
		from
			Param as p
	),
	BITMAPINFOHEADER as (
		select
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 15, 4), 2))) )as biSize,
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 19, 4), 2))) )as biWidth,
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 23, 4), 2))) )as biHeight,
			convert(int, convert(binary(2), reverse(convert(binary(2), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 27, 2), 2))) )as biPlanes
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