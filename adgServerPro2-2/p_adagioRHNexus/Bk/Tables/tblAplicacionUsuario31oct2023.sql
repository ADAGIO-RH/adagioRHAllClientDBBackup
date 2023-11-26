USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblAplicacionUsuario31oct2023](
	[IDAplicacionUsuario] [int] IDENTITY(1,1) NOT NULL,
	[IDAplicacion] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[AplicacionPersonalizada] [bit] NULL
) ON [PRIMARY]
GO
