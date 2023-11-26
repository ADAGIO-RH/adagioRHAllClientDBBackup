USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PROCOM].[tblClienteCuotaAfiliacion](
	[IDClienteCuotaAfiliacion] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[Anio] [int] NOT NULL,
	[Cuota] [decimal](18, 2) NULL,
	[Descripcion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaVigencia] [date] NULL,
 CONSTRAINT [PK_ProcomTblClienteCuotaAfiliacion_IDClienteCuotaAfiliacion] PRIMARY KEY CLUSTERED 
(
	[IDClienteCuotaAfiliacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [PROCOM].[tblClienteCuotaAfiliacion]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatClientes_ProcomTblClienteCuotaAfiliacion_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [PROCOM].[tblClienteCuotaAfiliacion] CHECK CONSTRAINT [FK_RHTblCatClientes_ProcomTblClienteCuotaAfiliacion_IDCliente]
GO
