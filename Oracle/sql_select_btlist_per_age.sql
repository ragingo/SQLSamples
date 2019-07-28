select
    age,
    listagg(blood_type, ',') within group (order by age) as blood_type_list
from
    (select
        age,
        blood_type
    from
        person
    group by
        age,
        blood_type
    )
group by
    age
;