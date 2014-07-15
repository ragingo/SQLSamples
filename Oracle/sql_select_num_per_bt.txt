select
    blood_type as "血液型",
    count(*) as "人数"
from
    person
group by
    blood_type
;
