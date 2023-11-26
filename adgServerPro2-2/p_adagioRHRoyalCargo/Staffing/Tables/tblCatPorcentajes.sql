USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staffing].[tblCatPorcentajes](
	[IDPorcentaje] [int] IDENTITY(1,1) NOT NULL,
	[IDSucursal] [int] NULL,
	[PorcentajeInicial] [int] NULL,
	[PorcentajeFinal] [int] NULL,
	[Activo] [bit] NULL,
 CONSTRAINT [Pk_StaffingtblCatPorcentajes_IDPorcentaje] PRIMARY KEY CLUSTERED 
(
	[IDPorcentaje] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[IDSucursal] ASC,
	[PorcentajeInicial] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[IDSucursal] ASC,
	[PorcentajeFinal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Staffing].[tblCatPorcentajes]  WITH CHECK ADD  CONSTRAINT [FK_StaffingtblCatPorcentajes_RHtblCatSucursales_IDSucursal] FOREIGN KEY([IDSucursal])
REFERENCES [RH].[tblCatSucursales] ([IDSucursal])
GO
ALTER TABLE [Staffing].[tblCatPorcentajes] CHECK CONSTRAINT [FK_StaffingtblCatPorcentajes_RHtblCatSucursales_IDSucursal]
GO
