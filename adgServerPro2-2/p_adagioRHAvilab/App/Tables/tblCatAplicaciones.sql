USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblCatAplicaciones](
	[IDAplicacion] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Orden] [int] NULL,
	[Icon] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Url] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TraduccionCustom] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SoloEmpleados] [bit] NULL,
 CONSTRAINT [PK_AppTblCatAplicaciones_IDAplicacion] PRIMARY KEY CLUSTERED 
(
	[IDAplicacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_APPtblCatAplicaciones_IDAplicacion] ON [App].[tblCatAplicaciones]
(
	[IDAplicacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_APPtblCatAplicaciones_Orden] ON [App].[tblCatAplicaciones]
(
	[Orden] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
