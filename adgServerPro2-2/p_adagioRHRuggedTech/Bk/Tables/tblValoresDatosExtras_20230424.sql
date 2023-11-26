USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblValoresDatosExtras_20230424](
	[IDValorDatoExtra] [int] IDENTITY(1,1) NOT NULL,
	[IDDatoExtra] [int] NOT NULL,
	[IDReferencia] [int] NOT NULL,
	[Valor] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
