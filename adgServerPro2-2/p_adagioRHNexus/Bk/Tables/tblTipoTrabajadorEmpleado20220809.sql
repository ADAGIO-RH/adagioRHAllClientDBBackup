USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblTipoTrabajadorEmpleado20220809](
	[IDTipoTrabajadorEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoTrabajador] [int] NULL,
	[IDTipoContrato] [int] NULL
) ON [PRIMARY]
GO
