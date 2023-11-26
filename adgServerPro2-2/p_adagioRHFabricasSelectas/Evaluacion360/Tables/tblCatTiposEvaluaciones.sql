USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatTiposEvaluaciones](
	[IDTipoEvaluacion] [int] NOT NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[TiposDeGrupos] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[BackGroundColor] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FontColor] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Fk_Evaluacion360TblCatTiposEvaluaciones_IDTipoEvaluacion] PRIMARY KEY CLUSTERED 
(
	[IDTipoEvaluacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblCatTiposEvaluaciones]  WITH CHECK ADD  CONSTRAINT [Chk_Evaluacion360TblCatTiposEvaluaciones_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [Evaluacion360].[tblCatTiposEvaluaciones] CHECK CONSTRAINT [Chk_Evaluacion360TblCatTiposEvaluaciones_Traduccion]
GO
