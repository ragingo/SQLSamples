with
    data (a, b, c, d) as (
        select 0, 0, 0, 0 from dual union all
        select 0, 0, 1, 0 from dual union all
        select 0, 0, 1, 1 from dual union all
        select 0, 1, 0, 0 from dual union all
        select 0, 1, 0, 1 from dual union all
        select 0, 1, 1, 0 from dual union all
        select 0, 1, 1, 1 from dual union all
        select 1, 0, 0, 0 from dual union all
        select 1, 0, 1, 0 from dual union all
        select 1, 0, 1, 1 from dual union all
        select 1, 1, 0, 0 from dual union all
        select 1, 1, 0, 1 from dual union all
        select 1, 1, 1, 0 from dual union all
        select 1, 1, 1, 1 from dual
    )
select
    d.*,
    (case
        when (a, b) = ((c, d)) then '○' else '✕'
    end) as chk
from
    data d