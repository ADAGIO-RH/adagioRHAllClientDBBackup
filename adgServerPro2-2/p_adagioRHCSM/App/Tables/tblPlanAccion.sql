USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblPlanAccion](
	[IDPlanAccion] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoPlanAccion] [int] NOT NULL,
	[IDReferencia] [int] NULL,
	[Fecha] [date] NOT NULL,
	[Accion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[PorcentajeAlcanzado] [decimal](18, 2) NOT NULL,
	[IDEstatusPlanAccionObjetivo] [int] NOT NULL,
	[IDUsuarioResponsable] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
