USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblVacacionesReporteAPI](
	[IDEmpleado] [int] NULL,
	[Anio] [int] NULL,
	[DiasAniosPrestacion] [int] NULL,
	[VacacionesGeneradas] [decimal](18, 2) NULL,
	[DiasTomados] [decimal](18, 2) NULL,
	[DiasVencidos] [decimal](18, 2) NULL,
	[DiasDisponibles] [decimal](18, 2) NULL,
	[Errores] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Proporcional] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
