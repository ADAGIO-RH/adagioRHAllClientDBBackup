USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblEmpleadoPTU20230508](
	[IDEmpleadoPTU] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[PTU] [bit] NULL
) ON [PRIMARY]
GO
