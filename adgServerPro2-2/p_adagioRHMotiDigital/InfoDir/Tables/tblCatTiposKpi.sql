USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InfoDir].[tblCatTiposKpi](
	[IDTipoKpi] [int] NOT NULL,
	[Tipo] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [Pk_InfoDirtblCatTiposKpi_IDTipoKpi] PRIMARY KEY CLUSTERED 
(
	[IDTipoKpi] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
