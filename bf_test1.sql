use sample
go

if object_id('bf_tape') is not null
	drop table bf_tape
go

with
	sequence(x) as (
		select 1
		union all
		select
			x + 1
		from
			sequence
		where
			x < 30000
	)
select
	x as id,
	0 as value
into
	bf_tape
from
	sequence

option (MAXRECURSION 0)

go

--------------------------------------------------------------------------------------------
declare @code varchar(max) = '+++++++++[>++++++++>+++++++++++>+++++<<<-]>.>++.+++++++..+++.>-.------------.<++++++++.--------.+++.------.--------.>+.'
declare @codepos int = 1
declare @ptr int = 1
declare @output varchar(max) = ''

while 1=1
begin
	declare @ch char(1) = substring(@code, @codepos, 1)
	declare @val int = 0

	if @ch = ' '
		break
	if @ch = '.'
		begin
			select @val = value from bf_tape where id = @ptr
			print char(@val)
			set @output += char(@val)
		end
	if @ch = '+'
		begin
			select @val = value from bf_tape where id = @ptr
			set @val += 1
			update bf_tape set value = @val where id = @ptr
		end
	if @ch = '-'
		begin
			select @val = value from bf_tape where id = @ptr
			set @val -= 1
			update bf_tape set value = @val where id = @ptr
		end
	if @ch = '>'
		begin
			set @ptr += 1
		end
	if @ch = '<'
		begin
			set @ptr -= 1
		end
	if @ch = '['
		begin
			select @val = value from bf_tape where id = @ptr
			if @val > 0
				begin
					set @codepos += 1
					continue
				end
			if @val = 0
				begin
					while 1=1
					begin
						set @codepos += 1
						declare @ch2 char(1) = substring(@code, @codepos, 1)
						if @ch2 = ']'
							begin
								break
							end
					end
				end
		end
	if @ch = ']'
		begin
			while 1=1
			begin
				set @codepos -= 1
				declare @ch3 char(1) = substring(@code, @codepos, 1)
				if @ch3 = '['
					begin
						set @codepos -= 1
						break
					end
			end
		end

	set @codepos += 1
end

select
	id,
	value
from
	bf_tape

print @output

