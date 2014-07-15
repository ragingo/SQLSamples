
with
    emp2 as (
        select
            rownum as num,
            level as lv,
            connect_by_isleaf as isleaf,
            e.*
        from
            emp e
        start with
            e.mgr is null
        connect by
            prior e.empno = e.mgr
    )
select
    e.num,
    e.deptno,
    e.lv,
    e.isleaf,
    (case
        when e.lv > 1 then
            case
                when e.isleaf = 0 then
                    lpad(' ', e.lv*2-3) || 
                        (case
                            when lead(e.lv) over(order by e.num) = e.lv then '├'
                            else '└'
                        end)
                else
                    lpad(' ', e.lv+1) ||
                        (case
                            when lead(e.lv) over(order by e.num) = e.lv then '├'
                            else '└'
                        end)
            end
        else
            null
    end) || e.empno as empno,
    e.ename,
    e.job,
    e.mgr
from
    emp2 e
;