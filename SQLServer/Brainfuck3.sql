-- SQL Server 2025 で動作確認
with
    -- Brainfuck コード
    input as (
        select '+++++++++[>++++++++>+++++++++++>+++++<<<-]>.>++.+++++++..+++.>-.------------.<++++++++.--------.+++.------.--------.>+.' as code
    ),
    -- Step 1 コードを分解し縦に並べる
    -- code: ソースコード
    -- length: ソースコードの文字列長
    -- idx: 1始まりのインデックス (1文字1行になるため、max(idx) = length)
    -- ch: 1文字 (code[idx])
    parse1(code, length, idx, ch) as (
        select
            code,
            len(code),
            1,
            substring(code, 1, 1)
        from
            input
        union all
        select
            code,
            len(code),
            idx + 1,
            substring(code, idx + 1, 1)
        from
            parse1
        where
            idx < len(code)
    ),
    -- Step 2 コードを解析しつつ実行
    -- arr: "ptr1=val1,ptr2=val2"
    -- ptr: 現在のポインタ (<>で移動。0始まり。)
    -- val: 現在のポインタが指す位置にある値
    -- loop_begin: ループ開始インデックス ([ が登場したときの idx を保持)
    parse2(length, idx, ch, arr, ptr, val, loop_begin) as (
        select
            p.length,
            p.idx,
            cast(p.ch as varchar),
            cast(case p.ch
                when '+' then '0=1'
                when '-' then '0=-1'
                else ''
            end as varchar(8000)),
            case p.ch
                when '>' then 1
                when '<' then - 1
                else 0
            end,
            case p.ch
                when '+' then 1
                when '-' then -1
                else 0
            end,
            0
        from
            parse1 as p
        where
            idx = 1
        union all
        select
            p1.length,
            case p1.ch
                when ']' then
                    case
                        when val > 0 then loop_begin
                        else p1.idx
                    end
                else p1.idx
            end,
            cast(p1.ch as varchar),
            case p1.ch
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
            case p1.ch
                when '>' then ptr + 1
                when '<' then ptr - 1
                else ptr
            end,
            case p1.ch
                when '+' then cast(regexp_substr(arr, concat(ptr, '=(-?\d+)'), 1, 1, 'i', 1) as int) + 1
                when '-' then cast(regexp_substr(arr, concat(ptr, '=(-?\d+)'), 1, 1, 'i', 1) as int) - 1
                when '>' then coalesce(regexp_substr(arr, concat(ptr + 1, '=(-?\d+)'), 1, 1, 'i', 1), 0)
                when '<' then coalesce(regexp_substr(arr, concat(ptr - 1, '=(-?\d+)'), 1, 1, 'i', 1), 0)
                else val
            end,
            case p1.ch
                when '[' then p1.idx
                when ']' then
                    case
                        when val > 0 then loop_begin
                        else p1.idx
                    end
                else loop_begin
            end
        from
            parse1 as p1
            inner join parse2 as p2 on p2.idx = p1.idx - 1
        where
            p1.idx > 1 and
            p1.idx <= p1.length
    ),
    -- Step 3 実行結果を出力
    parse3 as (
        select
            *,
            case ch
                when '.' then char(val)
                else null
            end as output
        from
            parse2
    )
select
    *
from
    parse3
where
    idx > 0 and
    output is not null
option (maxrecursion 10000)
