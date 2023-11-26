USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblMenuBK](
	[IDMenu] [int] IDENTITY(1,1) NOT NULL,
	[IDUrl] [int] NOT NULL,
	[ParentID] [int] NOT NULL,
	[CssClass] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Orden] [int] NULL
) ON [PRIMARY]
GO
