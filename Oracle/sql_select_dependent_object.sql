-- 実行計画を削除
delete from plan_table;
commit;

-- 実行計画を登録
explain plan for
select
    d.deptno,
    d.dname,
    e.empno,
    e.ename
from
    emp e
    inner join dept d on d.deptno = e.deptno;

-- 実行計画から、使用されているテーブルとビューの名称を取得
select distinct
    case
        when pt.object_type = any('TABLE', 'VIEW') then
            pt.object_name
        when instr(pt.object_type, 'INDEX') > 0 then
            (select ui.table_name from user_indexes ui where ui.index_name = pt.object_name)
    end as object_name
from
    plan_table pt
where
    pt.object_type is not null
order by
    object_name;