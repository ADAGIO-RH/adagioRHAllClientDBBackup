USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [STPS].[tblCatMunicipios](
	[IDMunicipio] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEstado] [int] NOT NULL,
 CONSTRAINT [PK_STPSTblCatMunicipios_IDMunicipio] PRIMARY KEY CLUSTERED 
(
	[IDMunicipio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_STPStblCatMunicipios_Codigo] ON [STPS].[tblCatMunicipios]
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_STPStblCatMunicipios_Descripcion] ON [STPS].[tblCatMunicipios]
(
	[Descripcion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_STPStblCatMunicipios_IDEstado] ON [STPS].[tblCatMunicipios]
(
	[IDEstado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [STPS].[tblCatMunicipios]  WITH CHECK ADD  CONSTRAINT [FK_STPStblCatEstados_STPStblCatMunicios_IDEstado] FOREIGN KEY([IDEstado])
REFERENCES [STPS].[tblCatEstados] ([IDEstado])
GO
ALTER TABLE [STPS].[tblCatMunicipios] CHECK CONSTRAINT [FK_STPStblCatEstados_STPStblCatMunicios_IDEstado]
GO
