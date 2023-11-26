USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatPlazas](
	[IDPlaza] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[Codigo] [App].[SMName] NOT NULL,
	[ParentId] [int] NOT NULL,
	[TotalPosiciones] [int] NOT NULL,
	[PosicionesOcupadas] [int] NOT NULL,
	[PosicionesDisponibles] [int] NOT NULL,
	[Configuraciones] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDPuesto] [int] NULL,
	[IDNivelSalarial] [int] NULL,
 CONSTRAINT [Pk_RHTblCatPlazas_IDPlaza] PRIMARY KEY CLUSTERED 
(
	[IDPlaza] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_RHTblCatPlazas_IDClienteCodigo] UNIQUE NONCLUSTERED 
(
	[IDCliente] ASC,
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
