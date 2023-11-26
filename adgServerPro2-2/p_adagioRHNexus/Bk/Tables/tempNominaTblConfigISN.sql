USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tempNominaTblConfigISN](
	[IDConfigISN] [int] NOT NULL,
	[IDEstado] [int] NOT NULL,
	[Porcentaje] [decimal](10, 2) NULL,
	[IDConceptos] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
