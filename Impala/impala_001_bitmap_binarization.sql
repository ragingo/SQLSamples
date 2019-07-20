with
    -- シーケンス 0 - 1
    seq2 as (
        select 0 as x
        union all select 1 as x
    ),
    -- シーケンス 0 - 3
    seq4 as (
        select row_number() over(order by a.x) - 1 as x from seq2 as a cross join seq2 as b
    ),
    -- シーケンス 0 - 15
    seq16 as (
        select row_number() over(order by a.x) - 1 as x from seq4 as a cross join seq4 as b
    ),
    -- シーケンス 0 - 255
    seq256 as (
        select row_number() over(order by a.x) - 1 as x from seq16 as a cross join seq16 as b
    ),
    -- シーケンス 0 - 65535
    seq65536 as (
        select row_number() over(order by a.x) - 1 as x from seq256 as a cross join seq256 as b
    ),
    -- 入力パラメータ
    input_param as (
        select
            50 as threshold,
            base64decode(
"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"
            ) as img
    ),
    --BITMAPFILEHEADER
    bitmap_file_header as (
        select 'bfType' as name,                 1 as pos, 2 as size
        union all select 'bfSize' as name,       3 as pos, 4 as size
        union all select 'bfReserved1' as name,  7 as pos, 2 as size
        union all select 'bfReserved2' as name,  9 as pos, 2 as size
        union all select 'bfOffBits' as name,   11 as pos, 4 as size
    ),
    --BITMAPINFOHEADER
    bitmap_info_header as (
        select 'biSize' as name,                    15 as pos, 4 as size
        union all select 'biWidth' as name,         19 as pos, 4 as size
        union all select 'biHeight' as name,        23 as pos, 4 as size
        union all select 'biPlanes' as name,        27 as pos, 2 as size
        union all select 'biBitCount' as name,      29 as pos, 2 as size
        union all select 'biCopmression' as name,   31 as pos, 2 as size
        union all select 'biSizeImage' as name,     33 as pos, 4 as size
        union all select 'biXPixPerMeter' as name,  37 as pos, 4 as size
        union all select 'biYPixPerMeter' as name,  41 as pos, 4 as size
        union all select 'biClrUsed' as name,       45 as pos, 4 as size
        union all select 'biCirImportant' as name,  49 as pos, 4 as size
    ),
    --ファイルヘッダのパース
    parsed_file_header as (
        select
            'file_header' as id,
            h.index,
            h.name,
            h.size,
            h.pos,
            (case
                when h.size = 1 then
                    (cast(conv(hex(substr(p.img, h.pos + 0, 1)), 16, 10) as int))
                when h.size = 2 then
                    (cast(conv(hex(substr(p.img, h.pos + 1, 1)), 16, 10) as int) +
                     cast(conv(hex(substr(p.img, h.pos + 0, 1)), 16, 10) as int))
                when h.size = 4 then
                    (cast(conv(hex(substr(p.img, h.pos + 3, 1)), 16, 10) as int) +
                     cast(conv(hex(substr(p.img, h.pos + 2, 1)), 16, 10) as int) +
                     cast(conv(hex(substr(p.img, h.pos + 1, 1)), 16, 10) as int) +
                     cast(conv(hex(substr(p.img, h.pos + 0, 1)), 16, 10) as int))
                else
                    0
             end
            ) as _data
        from
            input_param as p,
            (select
                row_number() over(order by bfh.pos) - 1 as index,
                bfh.name,
                bfh.pos,
                bfh.size
             from
                bitmap_file_header as bfh
            ) as h
    ),
    --情報ヘッダのパース
    parsed_info_header as (
        select
            'info_header' as id,
            h.index,
            h.name,
            h.size,
            h.pos,
            (case
                when h.size = 1 then
                    (cast(conv(hex(substr(p.img, h.pos + 0, 1)), 16, 10) as int))
                when h.size = 2 then
                    (cast(conv(hex(substr(p.img, h.pos + 1, 1)), 16, 10) as int) +
                     cast(conv(hex(substr(p.img, h.pos + 0, 1)), 16, 10) as int))
                when h.size = 4 then
                    (cast(conv(hex(substr(p.img, h.pos + 3, 1)), 16, 10) as int) +
                     cast(conv(hex(substr(p.img, h.pos + 2, 1)), 16, 10) as int) +
                     cast(conv(hex(substr(p.img, h.pos + 1, 1)), 16, 10) as int) +
                     cast(conv(hex(substr(p.img, h.pos + 0, 1)), 16, 10) as int))
                else
                    0
             end
            ) as _data
        from
            input_param as p,
            (select
                row_number() over(order by bih.pos) - 1 as index,
                bih.name,
                bih.pos,
                bih.size
             from
                bitmap_info_header as bih
            ) as h
    ),
    --データ取り出し
    bitmap_info as (
        select
            substr(p.img, b.offbits) as _data,
            a.pixel_count,
            a.width,
            a.height
        from
            input_param as p,
            --総ピクセル数, 幅, 高さ
            (select
                exp(sum(ln(_data))) as pixel_count,
                max(case name when 'biWidth' then _data else 0 end) as width,
                max(case name when 'biHeight' then _data else 0 end) as height
            from
                parsed_info_header
            where
                name in ('biWidth', 'biHeight')
            ) as a,
            --ファイル先頭から画像データまでのオフセット
            (select
                _data as offbits
            from
                parsed_file_header
            where name = 'bfOffBits'
            ) as b
    ),
    make_pix_sequence as (
        select
            cast(seq.x as int) as row_index
        from
            seq65536 as seq, bitmap_info as i
        where
            seq.x < (i.pixel_count)
    ),
    load_pixels as (
        select
            s.row_index as pos,
            cast(trunc(s.row_index / i.height) as int) as row_index,
            cast(s.row_index % i.height as int) as col_index,
            cast(conv(hex((substr(i._data, cast((s.row_index * 3) + 0 as int), 1))), 16, 10) as int) as red,
            cast(conv(hex((substr(i._data, cast((s.row_index * 3) + 1 as int), 1))), 16, 10) as int) as green,
            cast(conv(hex((substr(i._data, cast((s.row_index * 3) + 2 as int), 1))), 16, 10) as int) as blue,
            i.pixel_count
        from
            make_pix_sequence as s,
            bitmap_info as i
        order by
            pos,
            row_index,
            col_index
    ),
    binarize as (
        select
            p.pos,
            p.row_index,
            p.col_index,
            (case
                when p.red < param.threshold then 0
                when p.green < param.threshold then 0
                when p.blue < param.threshold then 0
                else 1
            end) as pix
        from
            input_param as param,
            load_pixels as p
        order by
            pos,
            row_index,
            col_index
    ),
    --可視化
    visualize as (
        select
            b.row_index,
            group_concat(case b.pix when 1 then '■' else '□' end, '') as a
        from
            binarize as b
        group by
            b.row_index
        order by
            row_index
    )
select
    *
from
    visualize
order by
    row_index desc
