select
    user_id,
    age,
    blood_type,
    count(blood_type) over(partition by age, blood_type) as count
from
    person
order by
    user_id
;
--確認用
select count(*) from person where age=82 and blood_type='O'
;