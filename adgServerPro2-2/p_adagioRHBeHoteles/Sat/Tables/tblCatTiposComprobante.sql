USE [p_adagioRHBeHoteles]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sat].[tblCatTiposComprobante](
	[IDTipoComprobante] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[ValorMaximo] [decimal](18, 4) NULL,
 CONSTRAINT [PK_tblCatTiposComprobante_IDTipoComprobante] PRIMARY KEY CLUSTERED 
(
	[IDTipoComprobante] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_tblCatTiposComprobante_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
