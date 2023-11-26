USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE Norma35.spPreguntasDominioReportesIndividuales --51
(
	@IDEncuestaEmpleado int
)
AS
BEGIN


	select  distinct
			D.Descripcion as Dominio
			,CDE.CalificacionLiteral  as Resultado
			from Norma35.tblEncuestasEmpleados EE
				inner join Norma35.tblEncuestas E
					on EE.IDEncuesta = E.IDEncuesta
				inner join Norma35.tblCatGrupos G
					on G.TipoReferencia = 2 and G.IDReferencia = EE.IDEncuestaEmpleado
				inner join Norma35.tblCatPreguntas p
					on p.IDCatGrupo = g.IDCatGrupo
				inner join Norma35.tblCatDominios D
					on P.IDDominio = D.IDDominio
				Inner join Norma35.tblCalificacionDominioEncuestas CDE
					on D.IDDominio = CDE.IDDominio
					and CDE.IDCatEncuesta = E.IDCatEncuesta
				--left join Norma35.tblCatEscalas esc
				--	on esc.IDCatEscala = p.IDCatEscala
				--left join Norma35.tblCatDetalleEscala DetEscala
				--	on DetEscala.IDCatEscala = esc.IDCatEscala
				inner join Norma35.tblRespuestasPreguntas rp
					on p.IDCatPregunta = rp.IDCatPregunta
		
				
			where ee.IDEncuestaEmpleado = @IDEncuestaEmpleado
			Group by D.Descripcion, CDE.Inicio, CDE.Fin,CDE.CalificacionLiteral
			Having SUM(rp.ValorFinal) Between CDE.Inicio and CDE.Fin
			ORDER BY D.Descripcion
END
GO
