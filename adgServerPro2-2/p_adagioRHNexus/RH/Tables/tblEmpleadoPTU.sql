USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblEmpleadoPTU](
	[IDEmpleadoPTU] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[PTU] [bit] NULL,
 CONSTRAINT [PK_RHTblEmpleadoPTU_IDEmpleadoPTU] PRIMARY KEY CLUSTERED 
(
	[IDEmpleadoPTU] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UC_RHTblEmpleadoPTU_IDEmpleado] UNIQUE NONCLUSTERED 
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblEmpleadoPTU_IDEmpleado] ON [RH].[tblEmpleadoPTU]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblEmpleadoPTU] ADD  DEFAULT ((1)) FOR [PTU]
GO
ALTER TABLE [RH].[tblEmpleadoPTU]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleado_RHTblEmpleadoPTU_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblEmpleadoPTU] CHECK CONSTRAINT [FK_RHTblEmpleado_RHTblEmpleadoPTU_IDEmpleado]
GO
