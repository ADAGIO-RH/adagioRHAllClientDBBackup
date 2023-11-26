USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Docs].[tblCatEstatusDocumento](
	[IDEstatusDocumento] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [PK_DocstblCatEstatusDocumento_IDEstatusDocumento] PRIMARY KEY CLUSTERED 
(
	[IDEstatusDocumento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_DocstblCatEstatusDocumento_Descripcion] UNIQUE NONCLUSTERED 
(
	[Descripcion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
