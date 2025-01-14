USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[UsuariosControllersAfter](
	[IDPermisoUsuarioController] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDController] [int] NOT NULL,
	[IDUrl] [int] NOT NULL,
	[TienePermiso] [bit] NULL,
	[UsuarioPermiso] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PERMISOCONTROLLER] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Prioridad] [int] NULL,
	[MaxUrl] [bigint] NULL
) ON [PRIMARY]
GO
