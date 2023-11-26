USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCajaAhorro20210107](
	[IDCajaAhorro] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Monto] [decimal](18, 2) NOT NULL,
	[IDEstatus] [int] NOT NULL
) ON [PRIMARY]
GO
