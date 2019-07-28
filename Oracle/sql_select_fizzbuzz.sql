select
    rownum as num,
    nvl(
        case when mod(rownum, 3) = 0 then 'Fizz' end ||
            case when mod(rownum, 5) = 0 then 'Buzz' end,
        rownum
    ) as val
from
    dual
connect by
    rownum <= 100
;