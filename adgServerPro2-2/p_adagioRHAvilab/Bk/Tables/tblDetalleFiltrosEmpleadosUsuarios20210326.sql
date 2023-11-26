USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblDetalleFiltrosEmpleadosUsuarios20210326](
	[IDDetalleFiltrosEmpleadosUsuarios] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Filtro] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[ValorFiltro] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCatFiltroUsuario] [int] NULL
) ON [PRIMARY]
GO
