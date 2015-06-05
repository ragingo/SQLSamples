
use sample
go

------------------------------------
-- 画像データ格納テーブル
------------------------------------
/*
create table image_data(
	id int not null primary key identity,
	name varchar(100),
	data varbinary(max)
)
go
*/

------------------------------------
-- 画像登録
------------------------------------
/*
insert into image_data(name, data)
select
	'Japan_24_64_48',
	(select * from openrowset(bulk N'C:\Users\Public\Pictures\Sample Pictures\Japan_24_64_48.bmp', SINGLE_BLOB) as bin)
go
*/

------------------------------------
-- 登録画像一覧
------------------------------------
--select * from image_data


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
			convert(char(2), convert(binary(2), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 1, 2), 2)) as bfType,
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata,  3, 4), 2)))) as bfSize,
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata,  7, 2), 2)))) as bfReserved1,
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata,  9, 2), 2)))) as bfReserved2,
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 11, 4), 2)))) as bfOffBits
		from
			Param as p
	),
	------------------------------------
	-- ビットマップ情報ヘッダ
	------------------------------------
	BITMAPINFOHEADER as (
		select
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 15, 4), 2)))) as biSize,
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 19, 4), 2)))) as biWidth,
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 23, 4), 2)))) as biHeight,
			convert(int, convert(binary(2), reverse(convert(binary(2), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 27, 2), 2)))) as biPlanes,
			convert(int, convert(binary(2), reverse(convert(binary(2), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 29, 2), 2)))) as biBitCount,
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 31, 4), 2)))) as biCopmression,
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 35, 4), 2)))) as biSizeImage,
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 39, 4), 2)))) as biXPixPerMeter,
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 43, 4), 2)))) as biYPixPerMeter,
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 47, 4), 2)))) as biClrUsed,
			convert(int, convert(binary(4), reverse(convert(binary(4), master.dbo.fn_varbintohexsubstring(0, p.rawdata, 51, 4), 2)))) as biCirImportant
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
	),
	------------------------------------
	-- ピクセル数分のシーケンス生成
	------------------------------------
	Seq(rowIndex, maxRowCount) as (
		select 0, (select PixelCount from BitmapInfo)
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
			s.rowIndex,
			convert(binary(1), master.dbo.fn_varbintohexsubstring(0, p.rawdata, (i.bfOffBits + 1) + (s.rowIndex * 3) + 0, 1), 2) as pix_r,
			convert(binary(1), master.dbo.fn_varbintohexsubstring(0, p.rawdata, (i.bfOffBits + 1) + (s.rowIndex * 3) + 1, 1), 2) as pix_g,
			convert(binary(1), master.dbo.fn_varbintohexsubstring(0, p.rawdata, (i.bfOffBits + 1) + (s.rowIndex * 3) + 2, 1), 2) as pix_b,
			i.*
		from
			Param as p,
			Seq as s,
			BitmapInfo i
		where
			s.rowIndex < s.maxRowCount / 3
	),
	------------------------------------
	-- 2値化
	------------------------------------
	Binarization as (
		select
			p.rowIndex as pos,
			round(p.rowIndex / p.biWidth, 0) as row_idx,
			p.rowIndex % p.biWidth as col_idx,
			(case
				when p.pix_r > Param.threshold then 1
				when p.pix_g > Param.threshold then 1
				when p.pix_b > Param.threshold then 1
				else 0
			end) as pix
		from
			RawPixels as p,
			(select 128 as threshold) as Param
	)
select
	*
into
	#temp_bin_image
from
	Binarization


option (maxrecursion 0)


------------------------------------
-- 列名一覧作成
------------------------------------
declare @col_list varchar(max) = ''

select
	@col_list = 
		@col_list +
		(case when len(@col_list) > 0 then ',' + char(13) else '' end) +
		'(case ' +
			'when max(case when col_idx = ' + cast(col_idx as varchar(max)) + ' then pix else 0 end) = 1 then ' +
				''''' ' +
			'else ' +
				'''■'' ' +
		'end) as _' + cast(col_idx as varchar(max))
from
	#temp_bin_image
group by
	col_idx
order by
	col_idx

------------------------------------
-- 出力
------------------------------------
declare @sql varchar(max) = 
	'select ' + char(13) +
		@col_list + char(13) +
	'from ' + char(13) +
		'#temp_bin_image ' + char(13) +
	'group by row_idx ' + char(13) +
	'order by row_idx desc'

print @sql
execute sp_sqlexec @sql

go

------------------------------------
-- 後始末
------------------------------------
drop table #temp_bin_image

go

