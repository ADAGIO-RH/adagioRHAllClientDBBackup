USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblPlanAccionObjetivos](
	[IDPlanAccionObjetivo] [int] IDENTITY(1,1) NOT NULL,
	[IDObjetivoEmpleado] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[Accion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[PorcentajeAlcanzado] [decimal](18, 2) NOT NULL,
	[IDEstatusPlanAccionObjetivo] [int] NOT NULL,
	[IDUsuarioResponsable] [int] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblPlanAccionObjetivos_IDPlanAccionObjetivo] PRIMARY KEY CLUSTERED 
(
	[IDPlanAccionObjetivo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblPlanAccionObjetivos] ADD  CONSTRAINT [D_Evaluacion360TblPlanAccionObjetivos_PorcentajeAlcanzado]  DEFAULT ((0)) FOR [PorcentajeAlcanzado]
GO
ALTER TABLE [Evaluacion360].[tblPlanAccionObjetivos]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblPlanAccionObjetivos_Evaluacion360TblCatEstatusObjetivosEmpleado_IDEstatusObjetivoEmpleado] FOREIGN KEY([IDEstatusPlanAccionObjetivo])
REFERENCES [Evaluacion360].[tblCatEstatusObjetivosEmpleado] ([IDEstatusObjetivoEmpleado])
GO
ALTER TABLE [Evaluacion360].[tblPlanAccionObjetivos] CHECK CONSTRAINT [Fk_Evaluacion360TblPlanAccionObjetivos_Evaluacion360TblCatEstatusObjetivosEmpleado_IDEstatusObjetivoEmpleado]
GO
