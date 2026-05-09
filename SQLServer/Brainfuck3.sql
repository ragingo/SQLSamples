-- SQL Server 2025 で動作確認
with
    -- Brainfuck コード
    input as (
        select '+++++++++[>++++++++>+++++++++++>+++++<<<-]>.>++.+++++++..+++.>-.------------.<++++++++.--------.+++.------.--------.>+.' as code
    ),
    -- デバッグ用
    tokens as (
        select '+' as ch, 'val_inc' as name
        union all
        select '-' as ch, 'val_dec'
        union all
        select '>' as ch, 'ptr_inc'
        union all
        select '<' as ch, 'ptr_dec'
        union all
        select '.' as ch, 'val_out'
        union all
        select '[' as ch, 'loop_begin'
        union all
        select ']' as ch, 'loop_end'
    ),
    -- デバッグ用
    tokenize(code, length, idx, ch, token) as (
        select
            code,
            len(code),
            1,
            substring(code, 1, 1),
            (select name from tokens where ch = substring(code, 1, 1))
        from
            input
        union all
        select
            code,
            len(code),
            idx + 1,
            substring(code, idx + 1, 1),
            (select name from tokens where ch = substring(code, idx + 1, 1))
        from
            tokenize
        where
            idx < len(code)
    ),
    -- arr: "ptr1=val1,ptr2=val2"
    parser1(length, idx, ch, token, arr, ptr, val, loop_begin) as (
        select
            t.length,
            t.idx,
            cast(t.ch as varchar),
            cast(t.token as varchar),
            cast(case t.ch
                when '+' then '0=1'
                when '-' then '0=-1'
                else ''
            end as varchar(8000)),
            case t.ch
                when '>' then 1
                when '<' then - 1
                else 0
            end,
            case t.ch
                when '+' then 1
                when '-' then -1
                else 0
            end,
            0
        from
            tokenize as t
        where
            idx = 1
        union all
        select
            t.length,
            case t.ch
                when ']' then
                    case
                        when val > 0 then loop_begin
                        else t.idx
                    end
                else t.idx
            end,
            cast(t.ch as varchar),
            cast(t.token as varchar),
            case t.ch
                when '+' then
                    regexp_replace(
                        arr,
                        concat(ptr, '=-?\d+'),
                        concat(ptr, '=', cast(cast(regexp_substr(arr, concat(ptr, '=(-?\d+)'), 1, 1, 'i', 1) as int) + 1 as varchar))
                    )
                when '-' then
                    regexp_replace(
                        arr,
                        concat(ptr, '=-?\d+'),
                        concat(ptr, '=', cast(cast(regexp_substr(arr, concat(ptr, '=(-?\d+)'), 1, 1, 'i', 1) as int) - 1 as varchar))
                    )
                when '>' then
                    case regexp_count(arr, concat(ptr + 1, '='))
                        when 0 then concat(arr, ',', cast(ptr + 1 as varchar), '=0')
                        else arr
                    end
                when '<' then
                    case regexp_count(arr, concat(ptr - 1, '='))
                        when 0 then concat(arr, ',', cast(ptr - 1 as varchar), '=0')
                        else arr
                    end
                else arr
            end,
            case t.ch
                when '>' then ptr + 1
                when '<' then ptr - 1
                else ptr
            end,
            case t.ch
                when '+' then cast(regexp_substr(arr, concat(ptr, '=(-?\d+)'), 1, 1, 'i', 1) as int) + 1
                when '-' then cast(regexp_substr(arr, concat(ptr, '=(-?\d+)'), 1, 1, 'i', 1) as int) - 1
                when '>' then coalesce(regexp_substr(arr, concat(ptr + 1, '=(-?\d+)'), 1, 1, 'i', 1), 0)
                when '<' then coalesce(regexp_substr(arr, concat(ptr - 1, '=(-?\d+)'), 1, 1, 'i', 1), 0)
                else val
            end,
            case t.ch
                when '[' then t.idx
                when ']' then
                    case
                        when val > 0 then loop_begin
                        else t.idx
                    end
                else loop_begin
            end
        from
            tokenize as t
            inner join parser1 as p on p.idx = t.idx - 1
        where
            t.idx > 1 and
            t.idx <= t.length
    ),
    parser2 as (
        select
            *,
            case ch
                when '.' then char(val)
                else null
            end as output
        from
            parser1
    )
select
    *
from
    parser2
where
    idx > 0 and
    output is not null
option (maxrecursion 10000)
