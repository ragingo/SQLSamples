
use sample
go

------------------------------------
-- ���͉摜�f�[�^�i�[�e�[�u��
------------------------------------
/*
create table image_data(
	id int not null identity(1,1) constraint PK_image_data primary key,
	name varchar(100),
	data varbinary(max)
)
go
*/

-- C:\Windows\Web\Wallpaper\Theme1\smile1.jpg -> D:\dev\data\smile1.bmp

------------------------------------
-- �摜�o�^
------------------------------------
/*
insert into image_data(name, data)
select
	'smile1_24_192_120',
	(select * from openrowset(bulk N'D:\dev\data\smile1.bmp', SINGLE_BLOB) as bin)
go
*/

------------------------------------
-- �o�͉摜�f�[�^�i�[�e�[�u��
------------------------------------
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
-- �O����
------------------------------------
truncate table result_image
go

------------------------------------
-- �r�b�g�}�b�v���擾
------------------------------------
with
	------------------------------------
	-- �Œ�p�����[�^
	------------------------------------
	Param as (
		select name, convert(varchar(max), data, 2) as data, data as rawdata from image_data where name = 'smile1_24_192_120'
	),
	------------------------------------
	-- �r�b�g�}�b�v�t�@�C���w�b�_
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
	-- �r�b�g�}�b�v���w�b�_
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
	-- �r�b�g�}�b�v���S��
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
	-- �s�N�Z�������̃V�[�P���X����
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
	-- �e�s�N�Z����RGB���擾
	------------------------------------
	RawPixels as (
		select
			s.rowIndex as pos,
			round(s.rowIndex / i.biWidth, 0) as row_index,
			s.rowIndex % i.biWidth as col_index,
			1 as alpha,
			dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata, i.bfOffBits + (s.rowIndex * 3) + 0, 1)) as red,
			dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata, i.bfOffBits + (s.rowIndex * 3) + 1, 1)) as green,
			dbo.Collection_Reverse(dbo.Collection_Range(p.rawdata, i.bfOffBits + (s.rowIndex * 3) + 2, 1)) as blue,
			i.*
		from
			Param as p,
			Seq as s,
			BitmapInfo i
		where
			s.rowIndex < s.maxRowCount / 3
	),
	------------------------------------
	-- �Œ�p�����[�^
	------------------------------------
	BinarizationParam as (
		select 160 as threshold
	),
	------------------------------------
	-- 2�l��
	------------------------------------
	Binarization as (
		select
			p.pos,
			p.row_index,
			p.col_index,
			(case
				when p.red < BinarizationParam.threshold then 0
				when p.green < BinarizationParam.threshold then 0
				when p.blue < BinarizationParam.threshold then 0
				else 1
			end) as pix
		from
			RawPixels as p,
			BinarizationParam
	)
insert into
	result_image
select
	*
from
	Binarization

option (maxrecursion 0)


------------------------------------
-- �񖼈ꗗ�쐬
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
				'''��'' ' +
		'end) as c' + cast(col_index as varchar(max))
from
	result_image
group by
	col_index
order by
	col_index

------------------------------------
-- �o��
------------------------------------
declare @sql varchar(max) =
	'select ' + char(13) +
		'row_index as r,' + char(13) +
		@col_list + char(13) +
	'from ' + char(13) +
		'result_image ' + char(13) +
	'group by row_index ' + char(13) +
	'order by row_index desc'

--print @sql
execute sp_sqlexec @sql

go
