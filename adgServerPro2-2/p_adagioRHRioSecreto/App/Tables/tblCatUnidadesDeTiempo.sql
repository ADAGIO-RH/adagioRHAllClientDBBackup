USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblCatUnidadesDeTiempo](
	[IDUnidadDeTiempo] [int] NOT NULL,
	[Nombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TiempoEnSegundos] [int] NOT NULL,
 CONSTRAINT [Pk_TblUnidadesDeTiempo_IDUnidadDeTiempo] PRIMARY KEY CLUSTERED 
(
	[IDUnidadDeTiempo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
