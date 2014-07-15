-- -- -- part1 -- -- --
select
    trunc(age/10)*10 as generation,
    sex,
    count(user_id) as num
from
    person
group by
    trunc(age/10)*10,
    sex
order by
    generation,
    sex
;
-- -- -- part2 -- -- --
select
    generation,
    sex,
    num
from
    person
group by
    trunc(age/10)*10,
    sex
model
    partition by (trunc(age/10)*10 as generation)
    dimension by (sex)
    measures (count(*) as num)
    rules
    (
        num[sex] = num[cv()]
    )
order by
    generation,
    sex
;
-- -- -- part3 -- -- --
select
    generation,
    sex,
    num
from
    person
group by
    trunc(age/10)*10,
    sex
model
    dimension by (trunc(age/10)*10 as generation, sex)
    measures (count(*) as num)
    rules
    (
        num[generation, sex] = num[cv(), cv()]
    )
order by
    generation,
    sex
;