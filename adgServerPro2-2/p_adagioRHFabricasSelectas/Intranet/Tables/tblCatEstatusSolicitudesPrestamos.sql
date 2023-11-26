USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Intranet].[tblCatEstatusSolicitudesPrestamos](
	[IDEstatusSolicitudPrestamo] [int] NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[CssClass] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEstatusSolicitudReferencia] [int] NULL,
	[VueBindingStyle] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_IntranetTblCatEstatusSolicitudesPrestamos_IDEstatusSolicitudPrestamo] PRIMARY KEY CLUSTERED 
(
	[IDEstatusSolicitudPrestamo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Intranet].[tblCatEstatusSolicitudesPrestamos] ADD  DEFAULT ('') FOR [VueBindingStyle]
GO
