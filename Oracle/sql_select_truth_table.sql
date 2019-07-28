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
    truth_table as (
        select
            to_number(d.input1) as input1,
            to_number(d.input2) as input2,
            to_number(utl_raw.bit_and(d.input1, d.input2)) as output_and,
            to_number(utl_raw.bit_or(d.input1, d.input2)) as output_or,
            to_number(utl_raw.bit_xor(d.input1, d.input2)) as output_xor,
            to_number(utl_raw.bit_and(utl_raw.bit_complement(utl_raw.bit_and(d.input1, d.input2)), hextoraw('00000001'))) as output_nand,
            to_number(utl_raw.bit_and(utl_raw.bit_complement(utl_raw.bit_or(d.input1, d.input2)), hextoraw('00000001'))) as output_nor
        from
            data2 d
    )
select
    t.input1,
    t.input2,
    t.output_and,
    t.output_or,
    t.output_xor,
    t.output_nand,
    t.output_nor
from
    truth_table t
;