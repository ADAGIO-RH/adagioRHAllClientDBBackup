USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatTiposPrestacionesDetalle](
	[IDTipoPrestacionDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoPrestacion] [int] NOT NULL,
	[Antiguedad] [int] NOT NULL,
	[DiasAguinaldo] [int] NULL,
	[DiasVacaciones] [int] NULL,
	[PrimaVacacional] [decimal](18, 4) NULL,
	[PorcentajeExtra] [decimal](18, 4) NULL,
	[DiasExtras] [int] NULL,
	[Factor]  AS (CONVERT([decimal](19,4),(((365)+[DiasAguinaldo])+[DiasVacaciones]*[PrimaVacacional])/(365))+[PorcentajeExtra]),
 CONSTRAINT [PK_RHTblCatTipoPrestacionesDetalle_IDTiposPrestacionesDetalle] PRIMARY KEY CLUSTERED 
(
	[IDTipoPrestacionDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_RHTblCatTiposPrestacionesDetalle_IDTipoPrestacion_ANTIGUEDAD] UNIQUE NONCLUSTERED 
(
	[IDTipoPrestacion] ASC,
	[Antiguedad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatTiposPrestacionesDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatTiposPrestaciones_RHtblCatTiposPrestacionesDetalle_IDTipoPrestacion] FOREIGN KEY([IDTipoPrestacion])
REFERENCES [RH].[tblCatTiposPrestaciones] ([IDTipoPrestacion])
GO
ALTER TABLE [RH].[tblCatTiposPrestacionesDetalle] CHECK CONSTRAINT [FK_RHtblCatTiposPrestaciones_RHtblCatTiposPrestacionesDetalle_IDTipoPrestacion]
GO
