USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblLevels](
	[Level] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Description] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_AppTblLevels_Level] PRIMARY KEY CLUSTERED 
(
	[Level] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
