USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatClasificacionesCorporativas](
	[IDClasificacionCorporativa] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [App].[MDDescription] NOT NULL,
	[CuentaContable] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_RHTblCatClasificacionesCorporativas_IDClasificacionCorporativa] PRIMARY KEY CLUSTERED 
(
	[IDClasificacionCorporativa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_RHtblCatClasificacionesCorporativas_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
