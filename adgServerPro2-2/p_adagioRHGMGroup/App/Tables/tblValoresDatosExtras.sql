USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblValoresDatosExtras](
	[IDValorDatoExtra] [int] IDENTITY(1,1) NOT NULL,
	[IDDatoExtra] [int] NOT NULL,
	[IDReferencia] [int] NOT NULL,
	[Valor] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_AppTblValoresDatosExtras_IDValorDatoExtra] PRIMARY KEY CLUSTERED 
(
	[IDValorDatoExtra] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [App].[tblValoresDatosExtras]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblValoresDatosExtras_AppTblCatDatosExtras_IDDatoExtra] FOREIGN KEY([IDDatoExtra])
REFERENCES [App].[tblCatDatosExtras] ([IDDatoExtra])
ON DELETE CASCADE
GO
ALTER TABLE [App].[tblValoresDatosExtras] CHECK CONSTRAINT [Fk_AppTblValoresDatosExtras_AppTblCatDatosExtras_IDDatoExtra]
GO
