-- 同名キーが在ったらアウト

with
    json_format as (
        select 'item1' as name, 'string' as type
        union all select 'item2' as name, 'number' as type
        union all select 'item3' as name, 'bool' as type
        union all select 'item4' as name, 'array_string' as type
    )
select
    f.name as json_key,
    regexp_extract(
        log.json_string,
        concat('"', f.name, '":',
            (case f.type
                when 'string' then '"(\\w+)"([,{}])'
                when 'array_string'  then '\\[(,?"\\w+")+\\]([,{}])'
                when 'number' then '(\\d+)([,{}])'
                when 'bool' then '(true|false)([,{}])'
            end)
        ),
        1
    ) as json_value,
    log.json_string
from
    access_log as log,
    json_format as f
