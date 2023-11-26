USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InfoDir].[tblCatPeriodos](
	[IDPeriodo] [int] NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Condicion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[OrdenPeriodo] [int] NULL,
	[Activo] [bit] NULL,
 CONSTRAINT [Pk_InfoDirtblCatPeriodos_IDPeriodo] PRIMARY KEY CLUSTERED 
(
	[IDPeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
