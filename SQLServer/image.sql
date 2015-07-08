
use sample
go



--drop table image_data
--truncate table image_data


------------------------------------
-- 入力画像データ格納テーブル
------------------------------------
/*
create table image_data(
	id int not null identity(1,1) constraint PK_image_data primary key,
	name varchar(100),
	data varbinary(max)
)
go
*/

------------------------------------
-- 出力画像データ格納テーブル
------------------------------------
/*
create table pixels(
	pos int not null,
	row_index int not null,
	col_index int not null,
	alpha tinyint not null,
	red tinyint not null,
	green tinyint not null,
	blue tinyint not null,
	constraint PK_pixels_rowcol primary key(row_index, col_index)
)
*/
/*
create table result_image(
	pos int not null,
	row_index int not null,
	col_index int not null,
	pix int not null,
	constraint PK_result_image_rowcol primary key(row_index, col_index)
)
*/

------------------------------------
-- 画像登録
------------------------------------
/*
insert into image_data(name, data)
select
	'Koala_24_256_192',
	(select * from openrowset(bulk N'C:\Users\Public\Pictures\Sample Pictures\Koala_24_256_192.bmp', SINGLE_BLOB) as bin)
go
*/

------------------------------------
-- 登録画像一覧
------------------------------------
--select * from image_data


------------------------------------
-- 前処理
------------------------------------
truncate table bitmap_info
truncate table pixels
truncate table result_image
go

------------------------------------
-- ビットマップ情報取得
------------------------------------
with
	------------------------------------
	-- 固定パラメータ
	------------------------------------
	Param as (
		select name, convert(varchar(max), data, 2) as data, data as rawdata from image_data where name = 'Koala_24_256_192'
	),
	------------------------------------
	-- ビットマップファイルヘッダ
	------------------------------------
	BITMAPFILEHEADER as (
		select
			convert(char(2), dbo.Collection_Range(p.rawdata, 0, 2)) as bfType,
			convert(int, dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata,  2, 4))) as bfSize,
			convert(int, dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata,  6, 2))) as bfReserved1,
			convert(int, dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata,  8, 2))) as bfReserved2,
			convert(int, dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata, 10, 4))) as bfOffBits
		from
			Param as p
	),
	------------------------------------
	-- ビットマップ情報ヘッダ
	------------------------------------
	BITMAPINFOHEADER as (
		select
			convert(int, dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata, 14, 4))) as biSize,
			convert(int, dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata, 18, 4))) as biWidth,
			convert(int, dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata, 22, 4))) as biHeight,
			convert(int, dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata, 26, 2))) as biPlanes,
			convert(int, dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata, 28, 2))) as biBitCount,
			convert(int, dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata, 30, 4))) as biCopmression,
			convert(int, dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata, 34, 4))) as biSizeImage,
			convert(int, dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata, 38, 4))) as biXPixPerMeter,
			convert(int, dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata, 42, 4))) as biYPixPerMeter,
			convert(int, dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata, 46, 4))) as biClrUsed,
			convert(int, dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata, 50, 4))) as biCirImportant
		from
			Param as p
	),
	------------------------------------
	-- ビットマップ情報全体
	------------------------------------
	BitmapInfo as (
		select
			bf.*,
			bi.*,
			(bi.biBitCount/8 * bi.biWidth * bi.biHeight) as PixelCount
		from
			BITMAPFILEHEADER bf,
			BITMAPINFOHEADER bi
	)
insert into bitmap_info
select
	*
from
	BitmapInfo

go

------------------------------------
-- 全ピクセルデータ取得
------------------------------------
with
	------------------------------------
	-- 固定パラメータ
	------------------------------------
	Param as (
		select name, convert(varchar(max), data, 2) as data, data as rawdata from image_data where name = 'Koala_24_256_192'
	),
	------------------------------------
	-- ピクセル数分のシーケンス生成
	------------------------------------
	Seq(rowIndex, maxRowCount) as (
		select 0, (select PixelCount from bitmap_info)
		union all
		select
			rowIndex+1, maxRowCount
		from
			Seq
		where
			rowIndex < maxRowCount
	),
	------------------------------------
	-- 各ピクセルのRGBを取得
	------------------------------------
	RawPixels as (
		select
			s.rowIndex as pos,
			round(s.rowIndex / i.biWidth, 0) as row_index,
			s.rowIndex % i.biWidth as col_index,
			dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata, i.bfOffBits + (s.rowIndex * 3) + 0, 1)) as red,
			dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata, i.bfOffBits + (s.rowIndex * 3) + 1, 1)) as green,
			dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata, i.bfOffBits + (s.rowIndex * 3) + 2, 1)) as blue,
			i.*
		from
			Param as p,
			Seq as s,
			bitmap_info i
		where
			s.rowIndex < s.maxRowCount / 3
	)
insert into pixels
select
	pos,
	row_index,
	col_index,
	1 as alpha,
	red,
	green,
	blue
from
	RawPixels

option (maxrecursion 0)

go

------------------------------------
-- 画像処理
------------------------------------
with
	Param as (
		select 128 as threshold
	),
	------------------------------------
	-- 2値化
	------------------------------------
	Binarization as (
		select
			p.pos,
			p.row_index,
			p.col_index,
			(case
				when p.red > Param.threshold then 1
				when p.green > Param.threshold then 1
				when p.blue > Param.threshold then 1
				else 0
			end) as pix
		from
			pixels as p,
			Param
	)
insert into result_image
select
	*
from
	Binarization

------------------------------------
-- 件数チェック
------------------------------------
if (select count(*) from result_image) = 0
begin
	print 'result_image is empty.'
	goto Finish
end

------------------------------------
-- 列名一覧作成
------------------------------------
declare @col_list varchar(max) = ''

select
	@col_list = 
		@col_list +
		(case when len(@col_list) > 0 then ',' + char(13) else '' end) +
		'(case ' +
			'when max(case when col_index = ' + cast(col_index as varchar(max)) + ' then pix else 0 end) = 1 then ' +
				''''' ' +
			'else ' +
				'''■'' ' +
		'end) as c' + cast(col_index as varchar(max))
from
	result_image
group by
	col_index
order by
	col_index

------------------------------------
-- 出力
------------------------------------
declare @sql varchar(max) =
	'select ' + char(13) +
		'row_index as r,' + char(13) +
		@col_list + char(13) +
	'from ' + char(13) +
		'result_image ' + char(13) +
	'group by row_index ' + char(13) +
	'order by row_index desc'

-- memo: 下記2行（出力・実行）で約2秒
--print @sql
execute sp_sqlexec @sql


------------------------------------
-- 後始末
------------------------------------
Finish:

go

