use sample
go

if object_id('NVarcharToUtf8') is not null
	drop function NVarcharToUtf8
go

create function NVarcharToUtf8(@str nvarchar(max))
returns varbinary(max)
as external name MSSQLLib.[MSSQLLib.CharsetUtils].NVarcharToUtf8
go

sp_configure 'clr enabled',1
GO
reconfigure
go

if object_id('UrlEncode') is not null
	drop function UrlEncode
go

create function UrlEncode(@str nvarchar(max))
returns varchar(max)
as
begin

	declare @pos int = 1
	declare @result varchar(max) = ''

	while 1=1
	begin
		declare @ret nvarchar(max)
		set @ret = substring(master.dbo.fn_varbintohexsubstring(1, dbo.NVarcharToUtf8(@str), @pos, 1), 3, 2)
		if isnull(@ret, '') = ''
			break
		set @result += '%' + isnull(@ret, '')
		set @pos += 1
	end

	return @result
end
go

