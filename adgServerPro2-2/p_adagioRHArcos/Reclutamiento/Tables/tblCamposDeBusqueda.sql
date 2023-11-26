USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblCamposDeBusqueda](
	[IDCamposDeBusqueda] [int] IDENTITY(1,1) NOT NULL,
	[Tabla] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Campo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_ReclutamientoCamposDeBusqueda] PRIMARY KEY CLUSTERED 
(
	[IDCamposDeBusqueda] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
