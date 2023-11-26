USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatDatosExtraClientes](
	[IDCatDatoExtraCliente] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [App].[MDName] NOT NULL,
	[Descripcion] [App].[LGDescription] NULL,
	[TipoDato] [App].[SMName] NOT NULL,
 CONSTRAINT [PK_RHTblCatDatosExtraClientews_IDCatDatoExtraCliente] PRIMARY KEY CLUSTERED 
(
	[IDCatDatoExtraCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_RHTblCatDatosExtraClientes_Nombre] UNIQUE NONCLUSTERED 
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
