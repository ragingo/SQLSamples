use sample
go

if object_id('section_paper') is not null
	drop table section_paper
go

-- •ûŠá†ì¬
create table section_paper(idx int)
go

declare @col_max int  = 360
declare @col_count int = 0
declare @sql varchar(max) = ''

while @col_count < @col_max
begin
	set @sql = ('alter table section_paper add col_' + cast(@col_count as varchar(10)) + ' nchar(1) default '' ''')
	execute sp_sqlexec @sql
	set @col_count += 1
end

go

with
	Seq(x) as (select 1 union all select x+1 from Seq where x < 1000)
insert into section_paper (idx)
select
	x-1
from
	Seq
option (MAXRECURSION 0)

go

declare @pos int
declare @amp float = 20
declare @freq float = 20.0
declare @start_y int = 50

declare @row_max int  = 360
declare @row_count int = 0
declare @sql varchar(max) = ''

begin transaction

while @row_count < @row_max
begin
	set @pos = round(@amp * sin(@row_count/180.0 * pi() * @freq), 0, 0);
	set @pos += @start_y
	set @sql = 'update section_paper set col_@col_no = ''œ'' where idx = @pos'
	set @sql = replace(@sql, '@col_no', @row_count)
	set @sql = replace(@sql, '@pos', @pos)
	execute sp_sqlexec @sql
	set @row_count += 1
end

commit

go

select
	*
from
	section_paper
order by
	idx
