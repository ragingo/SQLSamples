with
    data as (
        select
            rownum as num,
            to_char(sysdate + rownum, 'yyyy/mm/dd (DY)') as target,
            to_char(sysdate + rownum, 'eeyy/mm/dd (DY)', 'nls_calendar=''japanese imperial''') as target2,
            to_number(to_char(sysdate + rownum, 'mm')) as month,
            to_number(to_char(sysdate + rownum, 'dd')) as day,
            to_char(sysdate + rownum, 'DY') as week_of_day
        from
            dual
        connect by
            rownum <= 365 * 50
    )
select
    d.num || '日後(' || trunc(d.num/365) || '年後)' as msg,
    d.target,
    d.target2
from
    data d
where
    d.month = 10 and
    d.day = 8 and
    d.week_of_day = any('土', '日')
;