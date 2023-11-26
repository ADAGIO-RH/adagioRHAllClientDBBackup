USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Intranet].[tblConfigDashboardNomina](
	[IDConfigDashboardNomina] [int] NOT NULL,
	[BotonLabel] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Filtro] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [PK_IntranetTblConfigDashboardNomina_IDConfigDashboardNomina] PRIMARY KEY CLUSTERED 
(
	[IDConfigDashboardNomina] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
