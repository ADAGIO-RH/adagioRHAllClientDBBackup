USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblHistorialesEmpleadosPeriodos](
	[IDHistorialEmpleadoPeriodo] [int] NOT NULL,
	[IDPeriodo] [int] NULL,
	[IDEmpleado] [int] NULL,
	[IDCentroCosto] [int] NULL,
	[IDDepartamento] [int] NULL,
	[IDSucursal] [int] NULL,
	[IDPuesto] [int] NULL,
	[IDRegPatronal] [int] NULL,
	[IDCliente] [int] NULL,
	[IDEmpresa] [int] NULL,
	[IDArea] [int] NULL,
	[IDDivision] [int] NULL,
	[IDClasificacionCorporativa] [int] NULL,
	[IDRegion] [int] NULL,
	[IDRazonSocial] [int] NULL,
	[Asimilado] [bit] NULL
) ON [PRIMARY]
GO
