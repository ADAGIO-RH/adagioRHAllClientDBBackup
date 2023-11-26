USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[RH].[spBuscarCatCentroCosto] @IDUsuario= 1
--GO
CREATE PROCEDURE [RH].[spBuscarCatCentroCosto](
	@IDCentroCosto int =null
	,@CentroCosto Varchar(50) = null   
	,@IDUsuario int
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN
	SET FMTONLY OFF;  
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	;

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else @query  end

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
    IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	select ID   
	Into #TempFiltros  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'CentrosCostos'  
 
	SELECT 
		IDCentroCosto
		,Codigo
		,Descripcion
		,CuentaContable
		,isnull(ConfiguracionEventoCalendario, '{ "BackgroundColor": "#9999ff", "Color": "#ffffff" }') ConfiguracionEventoCalendario
		,ROWNUMBER = ROW_NUMBER()OVER(ORDER BY Codigo ASC) 
	into #TempResponse
	FROM RH.[tblCatCentroCosto]
	WHERE (IDCentroCosto = @IDCentroCosto or isnull(@IDCentroCosto,0) =0)
		--(Codigo LIKE @CentroCosto+'%') OR(Descripcion LIKE @CentroCosto+'%') OR (@CentroCosto IS NULL)
		--and ( (IDCentroCosto in  ( select ID from #TempFiltros)   OR Not Exists(select ID from #TempFiltros)) and  )   
        and (@query = '""' or contains(RH.tblCatCentroCosto.*, @query)) 
	ORDER BY Descripcion ASC

		select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDCentroCosto) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'asc'		then Codigo end,			
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'desc'	then Codigo end desc,
		Codigo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
