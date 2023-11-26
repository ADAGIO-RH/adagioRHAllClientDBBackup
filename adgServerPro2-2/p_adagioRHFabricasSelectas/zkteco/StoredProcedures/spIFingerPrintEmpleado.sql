USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc zkteco.spIFingerPrintEmpleado(
	@IDEmpleado int,
	@Content varchar(max) 
) as
	insert into zkteco.tblFingerPrintEmpleado(IDEmpleado, Content)
	values(@IDEmpleado, @Content)
GO
