select
    id,
    total
from
    (select 1 id, 100 value from dual union all
     select 2 id, 200 value from dual union all
     select 3 id, 300 value from dual union all
     select 1 id, 400 value from dual union all
     select 2 id, 500 value from dual union all
     select 3 id, 600 value from dual
    )
group by
    id
model
    dimension by (id)
    measures (sum(value) as total)
    rules
    (
        total[id] = total[cv()],
        total[null] = sum(total)[any]
    )
;