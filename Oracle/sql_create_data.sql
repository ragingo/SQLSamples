create table person (
    user_id       varchar2(100) not null,
    user_name     varchar2(200) not null,
    age           number(3,0) default 0 not null,
    sex           varchar2(7) default 'unknown' not null,
    blood_type    varchar2(7) default 'unknown' not null,
    constraint PK_USER primary key(user_id),
    constraint CHK_SEX check(sex in ('male', 'female', 'unknown')),
    constraint CHK_BLOOD_TYPE check(blood_type in ('A', 'B', 'O', 'AB', 'unknown'))
);

insert into person
with
    dummy_1mega as (
        select
            level as value
        from
            dual
        connect by
            rownum <= 1000000
    )
select
    'user_' || lpad(value, 10, 0) as user_id,
    'saku_' || lpad(value, 10, 0) as user_name,
    round(dbms_random.value * 100, 0) as age,
    case mod(round(dbms_random.value * 100, 0), 2)
        when 0 then 'male'
        when 1 then 'female'
    end as sex,
    case mod(round(dbms_random.value * 100, 0), 4)
        when 0 then 'A'
        when 1 then 'B'
        when 2 then 'O'
        when 3 then 'AB'
    end as blood_type
from
    dummy_1mega
;

commit;
