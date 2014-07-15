use sample
go

if object_id('HTTP_GET') is not null
	drop function HTTP_GET
go

create function HTTP_GET(@url varchar(max))
returns xml
as
begin
	declare @obj int
	declare @result int
	declare @status int
	declare @xml varchar(8000)

	exec @result = sp_OACreate 'MSXML2.XMLHttp', @obj out
	exec @result = sp_OAMethod @obj, 'open', NULL, 'GET', @url, false
	exec @result = sp_OAMethod @obj, 'setRequestHeader', NULL, 'Content-Type', 'application/x-www-form-urlencoded'
	exec @result = sp_OAMethod @obj, send, NULL, ''
	exec @result = sp_OAGetProperty @obj, 'status', @status out 
	exec @result = sp_OAGetProperty @obj, 'responseXML.xml', @xml out

	return @xml
end

go

