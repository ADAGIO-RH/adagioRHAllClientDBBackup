USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[clasCorp21102022](
	[IDClasificacionCorporativa] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [App].[MDDescription] NOT NULL,
	[CuentaContable] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY]
GO
