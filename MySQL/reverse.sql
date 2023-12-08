/*
+--------+------+------+--------+
| input  | i    | ch   | output |
+--------+------+------+--------+
| hello! |    6 | !    | !      |
| hello! |    5 | o    | !o     |
| hello! |    4 | l    | !ol    |
| hello! |    3 | l    | !oll   |
| hello! |    2 | e    | !olle  |
| hello! |    1 | h    | !olleh |
+--------+------+------+--------+
*/

with recursive
    params as (
        select
            "hello!" as input
    ),
    reverse(input, i, ch, output) as (
        select
            params.input,
            length(params.input),
            substr(params.input, length(params.input), 1),
            cast(
                substr(params.input, length(params.input), 1) as char(6)
            )
        from
            params
        union all
        select
            input,
            i - 1,
            substr(input, i - 1, 1),
            concat(output, substr(input, i - 1, 1))
        from
            reverse
        where
            i > 1
    )
select
    *
from
    reverse
