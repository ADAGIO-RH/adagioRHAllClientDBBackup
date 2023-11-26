USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROC [App].[spBuscarPlanAccion](
	 @IDPlanAccion int=0
    ,@IDTipoPlanAccion int=0
    ,@IDReferencia int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Fecha'
	,@orderDirection varchar(4) = 'desc'
	,@IDUsuario int
) as

	SET FMTONLY OFF;  

	DECLARE  
	   @TotalPaginas INT = 0
	   ,@TotalRegistros INT, 
		@IDIdioma VARCHAR(20)
	;

	SELECT @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	IF (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	IF (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	SELECT
		 @orderByColumn	 = CASE WHEN @orderByColumn	 IS NULL THEN 'Fecha' ELSE @orderByColumn  END
		,@orderDirection = CASE WHEN @orderDirection IS NULL THEN  'desc' ELSE @orderDirection END

	SET @query = CASE
					WHEN @query IS NULL THEN '""' 
					WHEN @query = '' THEN '""'
					WHEN @query =  '""' THEN '""'
				    ELSE '"'+@query + '*"' END

	IF OBJECT_ID('tempdb..#TempPlanAccion') IS NOT NULL DROP TABLE #TempPlanAccion; 

	SELECT 
		 PAO.*
         ,JSON_VALUE(EOE.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as EstatusPlanAccionObjetivo
	INTO #TempPlanAccion
	from App.tblPlanAccion PAO
    INNER JOIN Evaluacion360.tblCatEstatusObjetivosEmpleado EOE
        ON PAO.IDEstatusPlanAccionObjetivo=EOE.IDEstatusObjetivoEmpleado
	where 
		(PAO.IDPlanAccion = @IDPlanAccion or isnull(@IDPlanAccion,0) = 0)
		and (PAO.IDReferencia = @IDReferencia or isnull(@IDReferencia, 0) = 0)
        --and (@query = '""' or contains(PAO.*, @query)) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempPlanAccion

	select @TotalRegistros = cast(COUNT(IDPlanAccion) as decimal(18,2)) from #TempPlanAccion
	
	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempPlanAccion
	order by 	
		case when @orderByColumn = 'Fecha' and @orderDirection = 'asc'	then Fecha end,			
		case when @orderByColumn = 'Fecha' and @orderDirection = 'desc'	then Fecha end desc
			
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
