
--EXEC sp_configure 'clr enabled' , '1';
--RECONFIGURE;
--EXEC sp_configure 'clr enabled';

--go

--drop function [dbo].[Collection_Take]
--drop function [dbo].[Collection_Skip]
--drop function [dbo].[Collection_Range]
--drop function [dbo].[Collection_Length]

go

create function [dbo].[Collection_Take]
(
	@binary varbinary(max),
	@count int
)
returns varbinary(max)
as
external name [MSSqlUtils].[MSSqlUtils.Collection].[Take]

go

create function [dbo].[Collection_Skip]
(
	@binary varbinary(max),
	@count int
)
returns varbinary(max)
as
external name [MSSqlUtils].[MSSqlUtils.Collection].[Skip]

go

create function [dbo].[Collection_Range]
(
	@binary varbinary(max),
	@from int,
	@count int
)
returns varbinary(max)
as
external name [MSSqlUtils].[MSSqlUtils.Collection].[Range]

go

create function [dbo].[Collection_Length]
(
	@binary varbinary(max)
)
returns bigint
as
external name [MSSqlUtils].[MSSqlUtils.Collection].[Length]
