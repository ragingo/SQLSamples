create schema tbl1(a int, b int, c int);
​
-- 横持ちを縦持ちに変換
-- from 句にサブクエリ書くことができないから仕方ない
-- select 一発縛りが無ければ、随時 insert して中間結果を作っておくのもあり

select
  (case
    when t1.a is not null then "a"
    when t1.b is not null then "b"
    when t1.c is not null then "c"
    else ""
  end) as name,
  (case
    when t1.a is not null then t1.a
    when t1.b is not null then t1.b
    when t1.c is not null then t1.c
    else null
  end) as value
from
   tbl1 as t1
group by grouping sets( t1.a, t1.b, t1.c )
​
;
