use sample
go

if object_id('Beep') is not null
	drop function Beep
go

create function Beep(@frequency int, @duration int)
returns bit
as external name MSSQLLib.[MSSQLLib.SoundFunctions].Beep
go

sp_configure 'clr enabled',1
GO
reconfigure
go

