-- -- -- part1 -- -- --
with
    data as (
        select
            level as value
        from
            dual
        connect by
            rownum <= 9
    )
select
    1 * d.value,
    2 * d.value,
    3 * d.value,
    4 * d.value,
    5 * d.value,
    6 * d.value,
    7 * d.value,
    8 * d.value,
    9 * d.value
from
    data d
;
-- -- -- part2 -- -- --
with
    data as (
        select
            level as value
        from
            dual
        connect by
            rownum <= 9
    )
select
    *
from
    data
model
    dimension by (value r)
    measures (
        value as c1,
        value as c2,
        value as c3,
        value as c4,
        value as c5,
        value as c6,
        value as c7,
        value as c8,
        value as c9
    )
    rules (
        c1[for r from 1 to 9 increment 1] = 1 * c1[cv()],
        c2[for r from 1 to 9 increment 1] = 2 * c2[cv()],
        c3[for r from 1 to 9 increment 1] = 3 * c3[cv()],
        c4[for r from 1 to 9 increment 1] = 4 * c4[cv()],
        c5[for r from 1 to 9 increment 1] = 5 * c5[cv()],
        c6[for r from 1 to 9 increment 1] = 6 * c6[cv()],
        c7[for r from 1 to 9 increment 1] = 7 * c7[cv()],
        c8[for r from 1 to 9 increment 1] = 8 * c8[cv()],
        c9[for r from 1 to 9 increment 1] = 9 * c9[cv()]
    )
;