USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[tblCatTiposDenuncias](
	[IDTipoDenuncia] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Disponible] [bit] NULL,
 CONSTRAINT [Pk_Norma35tblCatTiposDenuncias_IDTipoDenuncia] PRIMARY KEY CLUSTERED 
(
	[IDTipoDenuncia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
