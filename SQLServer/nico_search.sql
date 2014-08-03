use sample
go

declare @nico_response table (id int identity(0,1), document xml, url varchar(max))

declare @cmsid varchar(20) = 'sm9'
declare @url varchar(max) = 'http://api.ce.nicovideo.jp/nicoapi/v1/video.info?v=' + @cmsid

insert into @nico_response(document, url)
select
	dbo.HTTP_GET(@url),
	@url


select
	x.id,
	'video.info' as api_name,
	x.document.value('(*/video/id)[1]', 'varchar(max)') as video_id,
	x.document.value('(*/video/user_id)[1]', 'varchar(max)') as user_id,
	x.document.value('(*/video/deleted)[1]', 'varchar(max)') as deleted,
	x.document.value('(*/video/title)[1]', 'varchar(max)') as title,
	x.document.value('(*/video/description)[1]', 'varchar(max)') as description,
	x.document.value('(*/video/length_in_seconds)[1]', 'varchar(max)') as length_in_seconds,
	x.document.value('(*/video/thumbnail_url)[1]', 'varchar(max)') as thumbnail_url,
	x.document.value('(*/video/upload_time)[1]', 'varchar(max)') as upload_time,
	x.document.value('(*/video/first_retrieve)[1]', 'varchar(max)') as first_retrieve,
	x.document.value('(*/video/view_counter)[1]', 'varchar(max)') as view_counter,
	x.document.value('(*/video/mylist_counter)[1]', 'varchar(max)') as mylist_counter,
	x.document.value('(*/video/option_flag_community)[1]', 'varchar(max)') as option_flag_community,
	x.document.value('(*/video/community_id)[1]', 'varchar(max)') as community_id,
	x.document.value('(*/video/vita_playable)[1]', 'varchar(max)') as vita_playable,
	x.document.value('(*/video/ppv_video)[1]', 'varchar(max)') as ppv_video,
	x.document.value('(*/video/provider_type)[1]', 'varchar(max)') as provider_type,
	x.document.value('(*/video/options/@mobile)[1]', 'varchar(max)') as options_mobile,
	x.document.value('(*/video/options/@large_thumbnail)[1]', 'varchar(max)') as options_large_thumbnail,
	x.document.value('(*/video/options/@adult)[1]', 'varchar(max)') as options_adult,
	x.document,
	x.url
from
	@nico_response x

delete from @nico_response
set @url = ''

declare @limit int = 100
declare @counter int = 0
declare @word varchar(max) = dbo.UrlEncode(N'LetItGo')

while @counter < @limit
begin
	declare @from varchar(3) = convert(varchar(3), @counter)
	set @url = 'http://api.ce.nicovideo.jp/nicoapi/v1/video.search?str=' + @word + '&limit=1&from=' + @from

	declare @doc xml = dbo.HTTP_GET(@url)

	declare @hit_count int
	select top 1 @hit_count = @doc.value('(*/count)[1]', 'int')

	if (@doc.value('(*/count)[1]', 'int') = 0 or
		@doc.value('(*/@status)[1]', 'varchar(10)') = 'fail')
		break

	insert into @nico_response(document, url) values(@doc, @url)

	set @counter += 1
end

select
	x.id,
	'video.search' as api_name,
	x.document.value('(*/*/video/id)[1]', 'varchar(max)') as video_id,
	x.document.value('(*/*/video/user_id)[1]', 'varchar(max)') as user_id,
	x.document.value('(*/*/video/deleted)[1]', 'varchar(max)') as deleted,
	x.document.value('(*/*/video/title)[1]', 'varchar(max)') as title,
	x.document.value('(*/*/video/description)[1]', 'varchar(max)') as description,
	x.document.value('(*/*/video/length_in_seconds)[1]', 'varchar(max)') as length_in_seconds,
	x.document.value('(*/*/video/thumbnail_url)[1]', 'varchar(max)') as thumbnail_url,
	x.document.value('(*/*/video/upload_time)[1]', 'varchar(max)') as upload_time,
	x.document.value('(*/*/video/first_retrieve)[1]', 'varchar(max)') as first_retrieve,
	x.document.value('(*/*/video/view_counter)[1]', 'varchar(max)') as view_counter,
	x.document.value('(*/*/video/mylist_counter)[1]', 'varchar(max)') as mylist_counter,
	x.document.value('(*/*/video/option_flag_community)[1]', 'varchar(max)') as option_flag_community,
	x.document.value('(*/*/video/community_id)[1]', 'varchar(max)') as community_id,
	x.document.value('(*/*/video/vita_playable)[1]', 'varchar(max)') as vita_playable,
	x.document.value('(*/*/video/ppv_video)[1]', 'varchar(max)') as ppv_video,
	x.document.value('(*/*/video/provider_type)[1]', 'varchar(max)') as provider_type,
	x.document.value('(*/*/video/options/@mobile)[1]', 'varchar(max)') as options_mobile,
	x.document.value('(*/*/video/options/@large_thumbnail)[1]', 'varchar(max)') as options_large_thumbnail,
	x.document.value('(*/*/video/options/@adult)[1]', 'varchar(max)') as options_adult,
	x.document,
	x.url
from
	@nico_response x
order by
	x.id

go

DBCC DROPCLEANBUFFERS
go

DBCC FREEPROCCACHE
go
