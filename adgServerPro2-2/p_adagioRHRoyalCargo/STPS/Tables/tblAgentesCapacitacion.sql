USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [STPS].[tblAgentesCapacitacion](
	[IDAgenteCapacitacion] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDTipoAgente] [int] NOT NULL,
	[Nombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Apellidos] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RFC] [varchar](13) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RegistroSTPS] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Contacto] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_StpsTblAgentesCapacitacion_IDAgenteCapacitacion] PRIMARY KEY CLUSTERED 
(
	[IDAgenteCapacitacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_StpsTblAgentesCapacitacion_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_STPStblAgentesCapacitacion_Codigo] ON [STPS].[tblAgentesCapacitacion]
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_STPStblAgentesCapacitacion_IDTipoAgente] ON [STPS].[tblAgentesCapacitacion]
(
	[IDTipoAgente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_STPStblAgentesCapacitacion_RFC] ON [STPS].[tblAgentesCapacitacion]
(
	[RFC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [STPS].[tblAgentesCapacitacion]  WITH CHECK ADD  CONSTRAINT [FK_StpsTblCatTiposAgentes_StpsTblAgentesCapacitacion_IDTipoAgente] FOREIGN KEY([IDTipoAgente])
REFERENCES [STPS].[tblCatTiposAgentes] ([IDTipoAgente])
GO
ALTER TABLE [STPS].[tblAgentesCapacitacion] CHECK CONSTRAINT [FK_StpsTblCatTiposAgentes_StpsTblAgentesCapacitacion_IDTipoAgente]
GO
