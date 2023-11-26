USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCatColonias20220929](
	[IDColonia] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDCodigoPostal] [int] NOT NULL,
	[NombreAsentamiento] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL
) ON [PRIMARY]
GO
