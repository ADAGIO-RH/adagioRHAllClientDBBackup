USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblEscalasValoracionesGrupos2270IDGrupo452](
	[IDEscalaValoracionGrupo] [int] IDENTITY(1,1) NOT NULL,
	[IDGrupo] [int] NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Valor] [int] NOT NULL
) ON [PRIMARY]
GO
