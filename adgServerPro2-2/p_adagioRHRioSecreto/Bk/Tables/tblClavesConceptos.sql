USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblClavesConceptos](
	[ClaveNueva] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ClaveVieja] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NombreConcepto] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY]
GO
