USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblRespuestasPreguntas](
	[IDRespuestaPregunta] [int] IDENTITY(1,1) NOT NULL,
	[IDEvaluacionEmpleado] [int] NOT NULL,
	[IDPregunta] [int] NOT NULL,
	[Respuesta] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaHoraRespuesta] [datetime] NULL,
	[Box9DesempenioActual] [int] NULL,
	[Box9DesempenioFuturo] [int] NULL,
	[ValorFinal] [decimal](18, 2) NULL,
 CONSTRAINT [Pk_Evaluacion360TblRespuestasPreguntas_IDRespuestaPregunta] PRIMARY KEY CLUSTERED 
(
	[IDRespuestaPregunta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblRespuestasPreguntas] ADD  CONSTRAINT [D_Evaluacion360TblRespuestasPreguntas_FechaHoraRespuesta]  DEFAULT (getdate()) FOR [FechaHoraRespuesta]
GO
ALTER TABLE [Evaluacion360].[tblRespuestasPreguntas]  WITH NOCHECK ADD  CONSTRAINT [Fk_Evaluacion360TblRespuestasPreguntas_Evaluacion360TblCatPreguntas_IDPregunta] FOREIGN KEY([IDPregunta])
REFERENCES [Evaluacion360].[tblCatPreguntas] ([IDPregunta])
GO
ALTER TABLE [Evaluacion360].[tblRespuestasPreguntas] CHECK CONSTRAINT [Fk_Evaluacion360TblRespuestasPreguntas_Evaluacion360TblCatPreguntas_IDPregunta]
GO
ALTER TABLE [Evaluacion360].[tblRespuestasPreguntas]  WITH NOCHECK ADD  CONSTRAINT [Fk_Evaluacion360TblRespuestasPreguntas_Evaluacion360TblEvaluacionesEmpleados_IDEvaluacionEmpleado] FOREIGN KEY([IDEvaluacionEmpleado])
REFERENCES [Evaluacion360].[tblEvaluacionesEmpleados] ([IDEvaluacionEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblRespuestasPreguntas] CHECK CONSTRAINT [Fk_Evaluacion360TblRespuestasPreguntas_Evaluacion360TblEvaluacionesEmpleados_IDEvaluacionEmpleado]
GO
