-- -- -- part1 -- -- --
select
    trunc(age/10)*10 as "年代",
    sum(case blood_type when 'A' then 1 else 0 end) as "A型",
    sum(case blood_type when 'B' then 1 else 0 end) as "B型",
    sum(case blood_type when 'O' then 1 else 0 end) as "O型",
    sum(case blood_type when 'AB' then 1 else 0 end) as "AB型"
from
    person
group by
    trunc(age/10)
order by
    "年代"
;
-- -- -- part2 -- -- --
select
    gen as "年代",
    a_cnt as "A型",
    b_cnt as "B型",
    o_cnt as "O型",
    ab_cnt as "AB型"
from
    (select trunc(age/10)*10 as gen, blood_type from person)
pivot
    (count(blood_type) as cnt for blood_type in (
        'A' as A,
        'B' as B,
        'O' as O,
        'AB' as AB
    ))
order by
    gen
;