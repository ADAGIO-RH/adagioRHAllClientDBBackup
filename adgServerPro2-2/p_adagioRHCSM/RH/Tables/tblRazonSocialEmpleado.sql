USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblRazonSocialEmpleado](
	[IDRazonSocialEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDRazonSocial] [int] NOT NULL,
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
 CONSTRAINT [PK_RHtblRazonSocialEmpleado_IDRazonSocialEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDRazonSocialEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblRazonSocialEmpleado_FechaFin] ON [RH].[tblRazonSocialEmpleado]
(
	[FechaFin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblRazonSocialEmpleado_FechaIni] ON [RH].[tblRazonSocialEmpleado]
(
	[FechaIni] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblRazonSocialEmpleado_IDEmpleado] ON [RH].[tblRazonSocialEmpleado]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblRazonSocialEmpleado_IDRazonSocial] ON [RH].[tblRazonSocialEmpleado]
(
	[IDRazonSocial] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblRazonSocialEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpleados_RHtblRazonSocialEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblRazonSocialEmpleado] CHECK CONSTRAINT [FK_RHtblEmpleados_RHtblRazonSocialEmpleado_IDEmpleado]
GO
ALTER TABLE [RH].[tblRazonSocialEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHtblRazonSocialEmpleado_RHtblCatRazonesSociales_IDRazonSocial] FOREIGN KEY([IDRazonSocial])
REFERENCES [RH].[tblCatRazonesSociales] ([IDRazonSocial])
GO
ALTER TABLE [RH].[tblRazonSocialEmpleado] CHECK CONSTRAINT [FK_RHtblRazonSocialEmpleado_RHtblCatRazonesSociales_IDRazonSocial]
GO
