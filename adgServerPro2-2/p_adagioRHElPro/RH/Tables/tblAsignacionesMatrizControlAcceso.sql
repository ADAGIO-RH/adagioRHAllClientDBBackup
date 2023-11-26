USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblAsignacionesMatrizControlAcceso](
	[IDAsignacionMatrizControlAcceso] [int] IDENTITY(1,1) NOT NULL,
	[IDMatrizControlAcceso] [int] NULL,
	[IDEmpleado] [int] NULL,
	[Value] [bit] NULL
) ON [PRIMARY]
GO
