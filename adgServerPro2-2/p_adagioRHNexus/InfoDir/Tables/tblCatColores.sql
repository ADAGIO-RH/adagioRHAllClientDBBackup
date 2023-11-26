USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InfoDir].[tblCatColores](
	[Color] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [Pk_InfoDirtblCatColores_Color] PRIMARY KEY CLUSTERED 
(
	[Color] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
