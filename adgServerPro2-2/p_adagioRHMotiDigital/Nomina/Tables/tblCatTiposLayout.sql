USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblCatTiposLayout](
	[IDTipoLayout] [int] IDENTITY(1,1) NOT NULL,
	[TipoLayout] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDBanco] [int] NULL,
	[IDConcepto] [int] NULL,
	[NombreProcedimiento] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_NominaTblCatTiposLayout_IDTipoLayout] PRIMARY KEY CLUSTERED 
(
	[IDTipoLayout] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblCatTiposLayout_IDBanco] ON [Nomina].[tblCatTiposLayout]
(
	[IDBanco] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblCatTiposLayout_IDConcepto] ON [Nomina].[tblCatTiposLayout]
(
	[IDConcepto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_NominatblCatTiposLayout_TipoLayout] ON [Nomina].[tblCatTiposLayout]
(
	[TipoLayout] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblCatTiposLayout]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatConceptos_NominaTblCatTiposLayout_IDConcepto] FOREIGN KEY([IDConcepto])
REFERENCES [Nomina].[tblCatConceptos] ([IDConcepto])
GO
ALTER TABLE [Nomina].[tblCatTiposLayout] CHECK CONSTRAINT [FK_NominaTblCatConceptos_NominaTblCatTiposLayout_IDConcepto]
GO
ALTER TABLE [Nomina].[tblCatTiposLayout]  WITH CHECK ADD  CONSTRAINT [FK_SATTblCatBancos_NominaTblCatTiposLayout_IDBanco] FOREIGN KEY([IDBanco])
REFERENCES [Sat].[tblCatBancos] ([IDBanco])
GO
ALTER TABLE [Nomina].[tblCatTiposLayout] CHECK CONSTRAINT [FK_SATTblCatBancos_NominaTblCatTiposLayout_IDBanco]
GO
