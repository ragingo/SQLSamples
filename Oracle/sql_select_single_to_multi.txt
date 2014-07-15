with
    data as (
        select
            rownum as num,
            (chr(ascii('a')+rownum-1) || ',' ||
             chr(ascii('a')+rownum+0) || ',' ||
             chr(ascii('a')+rownum+1)
            ) as value
        from
            dual
        connect by
            rownum <= 3
    ),
    records (num, value, split_value, pos, cnt) as (
        select
            num,
            value,
            regexp_substr(value, '[^,]', 1, 1) as split_value,
            1 as pos,
            regexp_count(value, '[^,]') as cnt
        from
            data
        union all
        select
            num,
            value,
            regexp_substr(value, '[^,]', 1, pos+1),
            pos + 1,
            cnt
        from
            records
        where
            pos < cnt
    )
select
    r.value,
    r.pos,
    r.split_value
from
    records r
order by
    r.num,
    r.pos
;
