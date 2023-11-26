USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblConfiguracionNominaRHFlex](
	[Configuracion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Valor] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[TipoDato] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY]
GO
