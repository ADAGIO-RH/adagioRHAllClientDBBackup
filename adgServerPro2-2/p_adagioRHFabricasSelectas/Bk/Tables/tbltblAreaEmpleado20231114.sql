USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tbltblAreaEmpleado20231114](
	[IDAreaEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDArea] [int] NOT NULL,
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NOT NULL
) ON [PRIMARY]
GO
