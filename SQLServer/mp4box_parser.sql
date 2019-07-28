use ragingo

drop table video
go

create table video (
    type varchar(max) not null,
    data varbinary(max) not null
)
go

insert into video(type, data)
select
    'mp4' as type,
    BulkColumn as data
from
    openrowset(bulk N'D:\temp\videos\dst.mp4', SINGLE_BLOB) as video_data
go

drop synonym dbo.read_bytes
go

create synonym read_bytes for master.dbo.fn_varbintohexsubstring
go


with
    parse_boxes(size, type, offset, data) as (
        select
            convert(int, convert(varbinary(max), dbo.read_bytes(1, data, 1, 4), 1)),
            convert(varchar(max), convert(varbinary(max), dbo.read_bytes(1, data, 1 + 4, 4), 1)),
            convert(int, convert(varbinary(max), dbo.read_bytes(1, data, 1, 4), 1)) + 1,
            data
        from
            video
        union all
        select
            convert(int, convert(varbinary(max), dbo.read_bytes(1, data, offset, 4), 1)),
            convert(varchar(max), convert(varbinary(max), dbo.read_bytes(1, data, offset + 4, 4), 1)),
            (case convert(varchar(max), convert(varbinary(max), dbo.read_bytes(1, data, offset + 4, 4), 1))
                -- box      : 4 + 4 (size + type)
                -- full box : 4 + 4 + 4 (box + version 8bit + flag 24bit)
                when 'moov' then 4 + 4
                when 'trak' then 4 + 4
                when 'edts' then 4 + 4
                when 'mdia' then 4 + 4
                when 'minf' then 4 + 4
                when 'dinf' then 4 + 4
                when 'dref' then 4 + 4 + 4 + 4 -- data reference box : full box + 4 (entry count)
                when 'stbl' then 4 + 4
                when 'stsd' then 4 + 4 + 4 + 4 -- sample description box : full box + 4 (entry count)
                --when 'avc1' then 4 + 4
                when 'udta' then 4 + 4
                when 'meta' then 4 + 4 + 4
                else convert(int, convert(varbinary(max), dbo.read_bytes(1, data, offset, 4), 1))
            end) + offset,
            data
        from
            parse_boxes
        where
            size is not null
    )
select
    size,
    type,
    offset - 1 as next_offset
from
    parse_boxes
option (maxrecursion 100)
