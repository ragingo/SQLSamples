select
    user_id,
    age as "(確認用)年齢",
    case (lag(age) over(order by user_id)) when age then null else age end as "年齢",
    sex as "(確認用)性別",
    case (lag(sex) over(order by user_id)) when sex then null else sex end as "性別",
    blood_type as "(確認用)血液型別",
    case (lag(blood_type) over(order by user_id)) when blood_type then null else blood_type end as "血液型別"
from
    person
;
