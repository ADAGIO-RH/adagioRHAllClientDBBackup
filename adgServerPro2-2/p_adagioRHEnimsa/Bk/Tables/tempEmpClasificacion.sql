USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tempEmpClasificacion](
	[ClaveEmpleado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ClasificacionCorporativa] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
