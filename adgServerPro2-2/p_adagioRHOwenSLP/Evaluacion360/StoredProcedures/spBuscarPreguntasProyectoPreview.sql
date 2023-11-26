USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar preguntas de proyecto
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-02-06
** Paremetros		:    



[Evaluacion360].[spBuscarPreguntasProyectoPreview] 119,1
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-02-07			Aneudy Abreu	Se agregaron los campos  Box9EsRequerido,Comentario,ComentarioEsRequerido 		
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBuscarPreguntasProyectoPreview](
	@IDProyecto int 
	,@IDUsuario int
) as
	 declare  
		   @IDIdioma Varchar(5)
		   ,@IdiomaSQL varchar(100) = null
	;
	
	SET DATEFIRST 7;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

    select @IdiomaSQL = [SQL]
    from app.tblIdiomas
    where IDIdioma = @IDIdioma

    if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
    begin
	   set @IdiomaSQL = 'Spanish' ;
    end
  
    SET LANGUAGE @IdiomaSQL;

	if object_id('tempdb..#tempGrupos') is not null drop table #tempGrupos;

	select 
		 cg.IDGrupo
		,cg.IDTipoGrupo
		,ctg.Nombre as TipoGrupo
		,cg.Nombre as Grupo
		,cg.Descripcion as DescripcionGrupo
		,isnull(cg.FechaCreacion,getdate()) as FechaCreacion
		,LEFT(DATENAME(WEEKDAY,isnull(cg.FechaCreacion,getdate())),3) + ' ' +
		  CONVERT(VARCHAR(6),isnull(cg.FechaCreacion,getdate()),106) 
		  + ' '+convert(varchar(4),datepart(year,isnull(cg.FechaCreacion,getdate()) ))
		  --' '+convert(varchar(5),cast(isnull(cg.FechaCreacion,getdate()) as time)) 
			FechaCreacionStr
		,cg.TipoReferencia
		,cg.IDReferencia
		,isnull(cg.CopiadoDeIDGrupo,0) as CopiadoDeIDGrupo
		,p.IDPregunta
		,p.IDTipoPregunta
		,p.Descripcion as Pregunta
		,p.EsRequerida
		,p.Calificar
		,p.Box9
		,isnull(p.IDCategoriaPregunta,0) as IDCategoriaPregunta
		,isnull(cp.Nombre,'Sin Categoría signada') as CategoriaPregunta
		,Completa = case when rp.IDRespuestaPregunta is not null then cast(1 as bit) else cast (0 as bit) end
		,rp.Respuesta
		,isnull(rp.Box9DesempenioActual,0) Box9DesempenioActual
		,isnull(rp.Box9DesempenioFuturo,0) Box9DesempenioFuturo
		,rp.Payload
		,GrupoEscala = case when exists (select top 1 1 
										from [Evaluacion360].[tblCatPreguntas] 
										where IDGrupo = cg.IDGrupo and (IDTipoPregunta = 8 OR IDTipoPregunta = 9) /*Escala*/)
							then cast(1 as bit) else cast(0 as bit) end
		,isnull(p.Box9EsRequerido,cast(0 as bit)) Box9EsRequerido
		,isnull(p.Comentario,cast(0 as bit)) Comentario
		,isnull(p.ComentarioEsRequerido,cast(0 as bit)) ComentarioEsRequerido
		,cg.Comentario AS ComentarioGrupo
		,ISNULL(cg.RequerirComentario, 0) as RequerirComentario
		,isnull(p.IDIndicador, 0) as IDIndicador
		,isnull(indicadores.Nombre, 'Sin Indicador') as Indicador
		,ROW_NUMBER()over(ORDER BY ctg.IDTipoGrupo, cg.Nombre,cp.Nombre asc) as [Row]
	from [Evaluacion360].[tblCatGrupos] cg
		join [Evaluacion360].[tblCatTipoGrupo] ctg  on cg.IDTipoGrupo = ctg.IDTipoGrupo
		join [Evaluacion360].[tblCatPreguntas] p on cg.IDGrupo = p.IDGrupo
		left join [Evaluacion360].[tblRespuestasPreguntas] rp on rp.IDEvaluacionEmpleado = cg.IDReferencia and rp.IDPregunta = p.IDPregunta
		left join [Evaluacion360].[tblCatCategoriasPreguntas] cp on p.IDCategoriaPregunta = cp.IDCategoriaPregunta
		left join [Evaluacion360].[tblCatIndicadores] indicadores on p.IDIndicador = indicadores.IDIndicador
	where-- cg.IDGrupo = @IDGrupo
		  -- and 
		  (cg.TipoReferencia = 1 and cg.IDReferencia = @IDProyecto)
	order by ctg.IDTipoGrupo, p.IDPregunta --cg.Nombre,cp.Nombre asc
GO
