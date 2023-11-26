USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[TBLCP](
	[CodigoPostal] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEstado] [int] NULL,
	[Estado] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDMunicipio] [int] NULL,
	[Municipio] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDLocalidad] [int] NULL,
	[Localidad] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY]
GO
