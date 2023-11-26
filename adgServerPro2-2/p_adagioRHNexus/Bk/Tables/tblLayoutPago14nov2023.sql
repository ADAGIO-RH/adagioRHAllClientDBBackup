USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblLayoutPago14nov2023](
	[IDLayoutPago] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoLayout] [int] NOT NULL,
	[Descripcion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDConcepto] [int] NOT NULL,
	[ImporteTotal] [int] NOT NULL,
	[IDConceptoFiniquito] [int] NULL,
	[ImporteTotalFiniquito] [int] NULL
) ON [PRIMARY]
GO
