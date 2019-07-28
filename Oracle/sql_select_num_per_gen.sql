select
    trunc(age/10)*10 as "年代",
    count(*) as "人数"
from
    person
group by
    trunc(age/10)
order by
    "年代"
;
