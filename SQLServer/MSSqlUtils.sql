/* アセンブリ作成時の権限について(https://msdn.microsoft.com/ja-jp/library/ms345106(v=sql.120).aspx)
use master
go

drop asymmetric key MSSqlUtilsKey
create asymmetric key MSSqlUtilsKey from executable file = 'D:\dev\src\my\SQLSamples\SQLServer\MSSqlUtils\MSSqlUtils\bin\Debug\MSSqlUtils.dll'
create login MSSqlUtilsLogin from asymmetric key MSSqlUtilsKey
grant unsafe assembly to MSSqlUtilsLogin
go
*/


use sample
go

drop function [dbo].[Collection_Take]
drop function [dbo].[Collection_Skip]
drop function [dbo].[Collection_Range]
drop function [dbo].[Collection_Length]
drop function [dbo].[Collection_Reverse]
drop procedure [dbo].[MultiMedia_PlaySound]

drop assembly MSSqlUtils;

go

create assembly MSSqlUtils
from 'D:\dev\src\my\SQLSamples\SQLServer\MSSqlUtils\MSSqlUtils\bin\Debug\MSSqlUtils.dll'
with permission_set=unsafe;

go

--EXEC sp_configure 'clr enabled' , '1';
--RECONFIGURE;
--EXEC sp_configure 'clr enabled';

--go

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

go

create function [dbo].[Collection_Reverse]
(
	@binary varbinary(max)
)
returns varbinary(max)
as
external name [MSSqlUtils].[MSSqlUtils.Collection].[Reverse]

go

create procedure [dbo].[MultiMedia_PlaySound]
(
	@path nvarchar(max)
)
as
external name [MSSqlUtils].[MSSqlUtils.MultiMedia].[PlaySound]
