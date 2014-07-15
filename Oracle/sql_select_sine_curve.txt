with
    data as (
        select
            rownum as num,
            trunc(amp * sin((rownum-1)/180 * 3.14 * freq) * 10) + 50 as pos
        from
            (select 1.5 as amp, 20 as freq from dual)
        connect by
            rownum <= 1000
    )

select
    lpad(' ', d.pos) || '*' || lpad(' ', d.pos) as plot
from
    data d
;
