USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar porcentajes
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-08-28
** Paremetros		: @IDPorcentaje			- Identificador del porcentaje.
					  @Porcentaje			- Numero de porcentaje.
					  @Activo				- Bandera de porcentaje habilitado o inhabilitado.
					  @IDUsuario			- Identificador del usuario.
					  @PageNumber			- Numero de pagina que se esta solicitando.
					  @PageSize				- Numero de registros de la pagina.
					  @query				- Cualquier descripcion que tenga relacion con la dirección.
					  @orderByColumn		- Los registros se ordenan por la columna solicitada.
					  @orderDirection 		- Los registros pueden ser ordenados por (ASC o DESC).
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [Staffing].[spBuscarPorcentajes](
	@IDPorcentaje	  INT = 0
	, @Porcentaje	  INT = 0
	, @Activo		  BIT = 1
	, @IDUsuario	  INT = 0
	, @PageNumber	  INT = 1
	, @PageSize		  INT = 2147483647
	, @query		  VARCHAR(100) = '""'
	, @orderByColumn  VARCHAR(50) = 'Porcentaje'
	, @orderDirection VARCHAR(4) = 'ASC'
)
AS
BEGIN

	SET FMTONLY OFF;  
	
	DECLARE @TotalPaginas	INT = 0,
			@TotalRegistros INT;

	IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
	IF(ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

	SET @query = CASE
					WHEN @query IS NULL THEN '""'
					WHEN @query = '' THEN '""'
					WHEN @query = '""' THEN @query
				 ELSE '"' + @query + '*"' END

	SELECT	@orderByColumn = CASE WHEN @orderByColumn IS NULL THEN 'Porcentaje' ELSE @orderByColumn END,
			@orderDirection = CASE WHEN @orderDirection IS NULL THEN 'ASC' ELSE @orderDirection END


	DECLARE @tempResponse AS TABLE (
		IDPorcentaje INT
		, Porcentaje INT
		, Activo BIT
		, ROWNUMBER INT
	);

	INSERT @tempResponse
	SELECT P.IDPorcentaje
		   , P.Porcentaje
		   , P.Activo
		   , ROWNUMBER = ROW_NUMBER()OVER(ORDER BY IDPorcentaje ASC) 
	FROM [Staffing].[tblCatPorcentajes] P
	WHERE ((P.IDPorcentaje = @IDPorcentaje OR ISNULL(@IDPorcentaje, 0) = 0)) 
		  AND ((P.Porcentaje = @Porcentaje OR ISNULL(@Porcentaje, 0) = 0)) 
		  --AND P.Activo = @Activo 
		  --AND (@query = '""' OR CONTAINS(P.*, @query)) 
	
	SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
	FROM @tempResponse

	SELECT @TotalRegistros = CAST(COUNT([IDPorcentaje]) AS DECIMAL(18,2)) FROM @tempResponse

	SELECT *,
			TotalPages = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
			CAST(@TotalRegistros AS INT) AS TotalRows
	FROM @tempResponse
	ORDER BY
		CASE WHEN @orderByColumn = 'Activo' and @orderDirection = 'asc'	THEN Porcentaje END
		, CASE WHEN @orderByColumn = 'Activo' and @orderDirection = 'desc' THEN Porcentaje END DESC
		, CASE WHEN @orderByColumn = 'Porcentaje'	and @orderDirection = 'asc'	THEN Porcentaje END
		, CASE WHEN @orderByColumn = 'Porcentaje'	and @orderDirection = 'desc' THEN Porcentaje END DESC
		, Porcentaje ASC, Activo ASC
	OFFSET @PageSize * (@PageNumber - 1) ROWS
	FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO
