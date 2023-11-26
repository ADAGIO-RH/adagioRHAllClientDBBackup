USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Transporte].[tblRutasProgramadasPersonal](
	[IDRutaProgramadaPersonal] [int] IDENTITY(1,1) NOT NULL,
	[IDRutaProgramada] [int] NULL,
	[IDRutaPersonal] [int] NULL
) ON [PRIMARY]
GO
