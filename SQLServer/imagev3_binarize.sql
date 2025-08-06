use tempdb

drop table img
go

create table img (
    type varchar(max) not null,
    data varbinary(max) not null
)
go

insert into img(type, data)
select
    'bmp' as type,
    BulkColumn as data
from
    openrowset(bulk N'D:\temp\images\catman.bmp', SINGLE_BLOB) as image_data
go

drop synonym dbo.read_bytes
go

create synonym read_bytes for master.dbo.fn_varbintohexsubstring
go

------------------------------------
-- ビットマップ情報取得
------------------------------------
with
    ------------------------------------
    -- 固定パラメータ
    ------------------------------------
    params as (
        select type, convert(varchar(max), data, 2) as data, data as rawdata from img where type = 'bmp'
    ),
    ------------------------------------
    -- ヘッダ
    ------------------------------------
    headers as (
        -- BITMAPFILEHEADER
        select
            header.name as header_name,
            cols.*
        from
            (
                select 'S' as data_type, 'bfType' as name, 1 as offset, 2 as length, 'B' as endian
                union all select 'N', 'bfSize',       3, 4, 'L'
                union all select 'N', 'bfReserved1',  7, 2, 'L'
                union all select 'N', 'bfReserved2',  9, 2, 'L'
                union all select 'N', 'bfOffBits',   11, 4, 'L'
            ) as cols,
            (select 'BITMAPFILEHEADER' as name) as header
        -- BITMAPINFOHEADER
        union all
        select
            header.name as header_name,
            cols.*
        from
            (
                select 'N' as data_type, 'biSize' as name, 15 as offset, 4 as length, 'L' as endian
                union all select 'N', 'biWidth',        19, 4, 'L'
                union all select 'N', 'biHeight',       23, 4, 'L'
                union all select 'N', 'biPlanes',       27, 2, 'L'
                union all select 'N', 'biBitCount',     29, 2, 'L'
                union all select 'N', 'biCopmression',  31, 4, 'L'
                union all select 'N', 'biSizeImage',    35, 4, 'L'
                union all select 'N', 'biXPixPerMeter', 39, 4, 'L'
                union all select 'N', 'biYPixPerMeter', 43, 4, 'L'
                union all select 'N', 'biClrUsed',      47, 4, 'L'
                union all select 'N', 'biCirImportant', 51, 4, 'L'
            ) as cols,
            (select 'BITMAPINFOHEADER' as name) as header
    ),
    parse_headers as (
        select
            h.*,
            dbo.read_bytes(1, p.rawdata, h.offset, h.length) as rawdata,
            case h.length
                when 1 then
                    convert(int, convert(varbinary(max), dbo.read_bytes(1, rawdata, h.offset, 1), 1))
                when 2 then
                    case h.endian
                        when 'B' then
                            (convert(int, convert(varbinary(max), dbo.read_bytes(1, rawdata, h.offset + 0, 1), 1)) << 8) +
                             convert(int, convert(varbinary(max), dbo.read_bytes(1, rawdata, h.offset + 1, 1), 1))
                        when 'L' then
                             convert(int, convert(varbinary(max), dbo.read_bytes(1, rawdata, h.offset + 0, 1), 1)) +
                            (convert(int, convert(varbinary(max), dbo.read_bytes(1, rawdata, h.offset + 1, 1), 1)) << 8)
                    end
                when 4 then
                    case h.endian
                        when 'B' then
                            (convert(int, convert(varbinary(max), dbo.read_bytes(1, rawdata, h.offset + 0, 1), 1)) << 24) +
                            (convert(int, convert(varbinary(max), dbo.read_bytes(1, rawdata, h.offset + 1, 1), 1)) << 16) +
                            (convert(int, convert(varbinary(max), dbo.read_bytes(1, rawdata, h.offset + 2, 1), 1)) <<  8) +
                             convert(int, convert(varbinary(max), dbo.read_bytes(1, rawdata, h.offset + 3, 1), 1))
                        when 'L' then
                             convert(int, convert(varbinary(max), dbo.read_bytes(1, rawdata, h.offset + 0, 1), 1)) +
                            (convert(int, convert(varbinary(max), dbo.read_bytes(1, rawdata, h.offset + 1, 1), 1)) <<  8) +
                            (convert(int, convert(varbinary(max), dbo.read_bytes(1, rawdata, h.offset + 2, 1), 1)) << 16) +
                            (convert(int, convert(varbinary(max), dbo.read_bytes(1, rawdata, h.offset + 3, 1), 1)) << 24)
                    end
            end as value
        from
            params as p,
            headers as h
    ),
    bitmap_info as (
        select
            max(case when name = 'biWidth' then ph.value else 0 end) as width,
            max(case when name = 'biHeight' then ph.value else 0 end) as height,
            max(case when name = 'bfSize' then ph.value else 0 end) as filesize,
            max(case when name = 'bfOffBits' then ph.value else 0 end) as img_offset
        from
            parse_headers as ph
        where
            name in ('biWidth', 'biHeight', 'bfSize', 'bfOffBits')
    ),
    bitmap_info2 as (
        select
            bi.*,
            ph.value / 8 as components,
            bi.width * bi.height as pixels,
            bi.width * bi.height * ph.value / 8 as bytes
        from
            parse_headers as ph,
            bitmap_info as bi
        where
            ph.name = 'biBitCount'
    ),
    bitmap_info3 as (
        select
            bi.*,
            -- オリジナルの img_offet は 0 始まり、read_bytes は 1 始まり
            convert(varbinary(max), dbo.read_bytes(1, p.rawdata, bi.img_offset + 1, bi.filesize - bi.img_offset + 1), 1) as img_data
        from
            params as p,
            bitmap_info2 as bi
    ),
    seq(pixel_index, pixel_count) as (
        select 0, (select pixels from bitmap_info3)
        union all
        select
            pixel_index + 1, pixel_count
        from
            seq
        where
            pixel_index < pixel_count
    ),
    ------------------------------------
    -- 各ピクセルのRGBを取得
    ------------------------------------
    load_pixels as (
        select
            s.pixel_index as pos,
            round(s.pixel_index / bi.height, 0) as row_index,
            s.pixel_index % bi.width as col_index,
            -- + 0, + 1, + 2 としたいところだが、1始まりのため各コンポーネントのオフセットは + 1, + 2, + 3
            convert(int, convert(varbinary(max), dbo.read_bytes(1, bi.img_data, s.pixel_index * 4 + 1, 1), 1)) as red,
            convert(int, convert(varbinary(max), dbo.read_bytes(1, bi.img_data, s.pixel_index * 4 + 2, 1), 1)) as green,
            convert(int, convert(varbinary(max), dbo.read_bytes(1, bi.img_data, s.pixel_index * 4 + 3, 1), 1)) as blue,
            convert(int, convert(varbinary(max), dbo.read_bytes(1, bi.img_data, s.pixel_index * 4 + 4, 1), 1)) as alpha
        from
            seq as s,
            bitmap_info3 as bi
    ),
    ------------------------------------
    -- 固定パラメータ
    ------------------------------------
    binarization_params as (
        select 160 as threshold
    ),
    ------------------------------------
    -- 2値化
    ------------------------------------
    binarize as (
        select
            p.pos,
            p.row_index,
            p.col_index,
            (case
                when p.red < params.threshold then 0
                when p.green < params.threshold then 0
                when p.blue < params.threshold then 0
                else 1
            end) as pix
        from
            load_pixels as p,
            binarization_params as params
    ),
    viewer as (
        select
            b.row_index,
            string_agg(
                case b.pix
                    when 0 then '■'
                    when 1 then '□'
                    else ''
                end,
                ''
            ) as row_pixels
        from
            binarize as b
        group by
            b.row_index
    )
select
    *
from
    viewer as v
order by
    v.row_index desc

option (maxrecursion 0)
