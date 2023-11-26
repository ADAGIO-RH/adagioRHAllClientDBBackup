USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sat].[tblCatEstados](
	[IDEstado] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[NombreEstado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDPais] [int] NOT NULL,
 CONSTRAINT [PK_tblCatEstados_IDEstado] PRIMARY KEY CLUSTERED 
(
	[IDEstado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_tblCatEstados_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Sat].[tblCatEstados]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatPaises_IDPais] FOREIGN KEY([IDPais])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [Sat].[tblCatEstados] CHECK CONSTRAINT [FK_SatTblCatPaises_IDPais]
GO
