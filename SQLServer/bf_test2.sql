-- SQL Server 2019 で動作確認
with
  input as (
    select
      --'+>+[-]+.' as code
      --'++[>++<-].' as code -- 0x04
      --'+++++++[>+++++++<-]>.' as code -- 1 (49, 0x31)
      '+++++++[>++++++++<-]>+.' as code -- 9 (0x39)
      --'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.' as code -- A
      --'>+[+[<]>>+<+]>.' as code -- ループのネストは非対応（むずかしい＞＜）
  ),
  bf(code, offset, op, tape, tape_ptr, depth, loop_begin, loop_end) as (
    select
      -- code
      code,
      -- offset
      1,
      -- op
      substring(code, 1, 1),
      -- tape
      convert(
        varbinary(1024),
        case substring(code, 1, 1)
          when '+' then char(1)
          when '-' then char(-1)
          else char(0)
        end
      ),
      -- tape_ptr
      case substring(code, 1, 1)
        when '>' then 2
        when '<' then 1
        else 1
      end,
      -- depth
      case substring(code, 1, 1)
        when '[' then  1
        when ']' then -1
        else 0
      end,
      -- loop_begin
      0,
      -- loop_end
      0
    from
      input
    union all
    select
      -- code
      code,
      -- offset
      case substring(code, offset + 1, 1)
        when '[' then
          case isnull(ascii(substring(tape, tape_ptr, 1)), 0)
            when 0 then loop_end - 1
            else offset + 1
          end
        when ']' then
          case isnull(ascii(substring(tape, tape_ptr, 1)), 0)
            when 0 then offset + 1
            else loop_begin - 1
          end
        else offset + 1
      end,
      -- op
      substring(code, offset + 1, 1),
      -- tape
      convert(
        varbinary(1024),
        case substring(code, offset + 1, 1)
          when '+' then
            concat(
              substring(tape, 1, tape_ptr - 1),
              char(isnull(ascii(substring(tape, tape_ptr, 1)), 0) + 1),
              substring(tape, tape_ptr + 1, 1024 - tape_ptr)
            )
          when '-' then
            concat(
              substring(tape, 1, tape_ptr - 1),
              char(isnull(ascii(substring(tape, tape_ptr, 1)), 0) - 1),
              substring(tape, tape_ptr + 1, 1024 - tape_ptr)
            )
          else tape
        end
      ),
      -- tape_ptr
      case substring(code, offset + 1, 1)
        when '>' then tape_ptr + 1
        when '<' then tape_ptr - 1
        else tape_ptr
      end,
      -- depth
      case substring(code, offset + 1, 1)
        when '[' then depth + 1
        when ']' then depth - 1
        else depth
      end,
      -- loop_begin
      case substring(code, offset + 1, 1)
        when '[' then offset + 1
        else loop_begin
      end,
      -- loop_end
      case substring(code, offset + 1, 1)
        when ']' then offset + 1
        else loop_end
      end
    from
      bf
    where
      offset < len(code)
  )
select
  *
from
  bf
option (MAXRECURSION 32767)
