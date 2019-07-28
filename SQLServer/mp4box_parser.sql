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
    parse_boxes(size, type, current_offset, next_offset, data) as (
        select
            convert(int, convert(varbinary(max), dbo.read_bytes(1, data, 1, 4), 1)),
            convert(varchar(max), convert(varbinary(max), dbo.read_bytes(1, data, 1 + 4, 4), 1)),
            1,
            convert(int, convert(varbinary(max), dbo.read_bytes(1, data, 1, 4), 1)) + 1,
            data
        from
            video
        union all
        select
            convert(int, convert(varbinary(max), dbo.read_bytes(1, data, next_offset, 4), 1)),
            convert(varchar(max), convert(varbinary(max), dbo.read_bytes(1, data, next_offset + 4, 4), 1)),
            next_offset,
            (case convert(varchar(max), convert(varbinary(max), dbo.read_bytes(1, data, next_offset + 4, 4), 1))
                -- box      : 4 + 4 (size + type)
                -- full box : 4 + 4 + 4 (box + version 8bit + flag 24bit)
                when 'moov' then 8
                when 'trak' then 8
                when 'edts' then 8
                when 'mdia' then 8
                when 'minf' then 8
                when 'dinf' then 8
                when 'dref' then 12 + 4 -- data reference box : full box + 4 (entry count)
                when 'stbl' then 8
                when 'stsd' then 12 + 4 -- sample description box : full box + 4 (entry count)
                when 'udta' then 8
                when 'meta' then 12
                else convert(int, convert(varbinary(max), dbo.read_bytes(1, data, next_offset, 4), 1))
            end) + next_offset,
            data
        from
            parse_boxes
        where
            size is not null
    ),
    parse_tkhd(size, type, current_offset, next_offset, data, track_id, duration, width, height) as (
        select
            size,
            type,
            current_offset,
            next_offset,
            data,
            convert(int, convert(varbinary(max), dbo.read_bytes(1, data, current_offset + 12 + 4 + 4, 4), 1)),
            convert(int, convert(varbinary(max), dbo.read_bytes(1, data, current_offset + 12 + 4 + 4 + 4, 8), 1)),
            convert(int, convert(varbinary(max), dbo.read_bytes(1, data, current_offset + 12 + 4 + 4 + 4 + 8 + 4 * 2 + 2 + 2 + 2 + 2 + 4 * 9, 2), 1)),
            convert(int, convert(varbinary(max), dbo.read_bytes(1, data, current_offset + 12 + 4 + 4 + 4 + 8 + 4 * 2 + 2 + 2 + 2 + 2 + 4 * 9 + 4, 2), 1))
        from
            parse_boxes
        where
            type = 'tkhd'
    ),
    parse_avc1(size, type, current_offset, next_offset, data, width, height) as (
        select
            size,
            type,
            current_offset,
            next_offset,
            data,
            -- sample entry (6 + 2) + visual sample entry (2 + 2 + 4 * 3 + 2 (w) + 2 (h))
            convert(int, convert(varbinary(max), dbo.read_bytes(1, data, current_offset + 8 + 6 + 2 + 2 + 2 + 4 * 3, 2), 1)),
            convert(int, convert(varbinary(max), dbo.read_bytes(1, data, current_offset + 8 + 6 + 2 + 2 + 2 + 4 * 3 + 2, 2), 1))
        from
            parse_boxes
        where
            type = 'avc1'
    ),
    dump as (
        select
            size,
            type,
            current_offset - 1 as current_offset,
            next_offset - 1 as next_offset
        from
            parse_boxes
    )
select
    *
from
    dump
option (maxrecursion 100)
