USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblHistorialPrimaRiesgo](
	[IDHistorialPrimaRiesgo] [int] IDENTITY(1,1) NOT NULL,
	[IDRegPatronal] [int] NOT NULL,
	[Anio] [int] NOT NULL,
	[Mes] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Prima] [decimal](21, 10) NOT NULL
) ON [PRIMARY]
GO
