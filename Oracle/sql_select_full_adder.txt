with
    data (input1, input2) as (
        select 0, 0 from dual union all
        select 0, 1 from dual union all
        select 1, 0 from dual union all
        select 1, 1 from dual
    ),
    data2 as (
        select
            utl_raw.cast_from_binary_integer(input1) as input1,
            utl_raw.cast_from_binary_integer(input2) as input2
        from
            data
    ),
    -- 半加算器
    half_adder as (
        select
            input1,
            input2,
            utl_raw.bit_or(
                utl_raw.bit_and(
                    input1,
                    utl_raw.bit_complement(input2)
                ),
                utl_raw.bit_and(
                    utl_raw.bit_complement(input1),
                    input2
                )
            ) as output_sum,
            utl_raw.bit_and(input1, input2) as output_carry
        from
            data2
    ),
    -- 全加算器
    full_adder as (
        select
            ha1.input1 as a,
            ha1.input2 as b,
            ha2.input2 as x,
            utl_raw.bit_or(
                ha1.output_carry,
                ha2.output_carry
            ) as c,
            ha2.output_sum as s
        from
            half_adder ha1
            inner join half_adder ha2 on
                ha1.output_sum = ha2.input1
    )
select
    to_number(fa.a) as a,
    to_number(fa.b) as b,
    to_number(fa.x) as x,
    to_number(fa.c) as c,
    to_number(fa.s) as s
from
    full_adder fa
order by
    fa.a || fa.b || fa.x
;