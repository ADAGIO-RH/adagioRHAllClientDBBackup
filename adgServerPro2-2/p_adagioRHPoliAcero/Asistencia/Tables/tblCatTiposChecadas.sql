USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblCatTiposChecadas](
	[IDTipoChecada] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[TipoChecada] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Activo] [bit] NULL,
 CONSTRAINT [PK_AsistenciaTblCatTiposChecadas_IDTipoChecada] PRIMARY KEY CLUSTERED 
(
	[IDTipoChecada] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblCatTiposChecadas] ADD  DEFAULT ((1)) FOR [Activo]
GO
