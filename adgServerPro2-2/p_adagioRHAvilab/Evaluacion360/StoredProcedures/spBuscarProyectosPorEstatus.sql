USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Busca proyectos por estatus
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2021-07-13
** Paremetros		:  @IdsEstatus varchar(max) - IDs separados por coma (,)
					   @IDUsuario int           

** DataTypes Relacionados: 

 Si se modifica el result set de este sp será necesario modificar también los siguientes SP's:
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2022-11-08			Alejandro Paredes	Se agrego la paginación
***************************************************************************************************/

CREATE PROC [Evaluacion360].[spBuscarProyectosPorEstatus](
	@IdsEstatus VARCHAR(MAX),
	@IDUsuario INT,
	@PageNumber	INT = 1,
	@PageSize INT = 2147483647,
	@query VARCHAR(100) = '""',
	@orderByColumn VARCHAR(50) = 'IDEstatus',
	@orderDirection VARCHAR(4) = 'ASC'
) AS

    SET FMTONLY OFF
		
		SET LANGUAGE 'Spanish';

		-- DECLARE
		-- @IdsEstatus VARCHAR(MAX) = '1,6'

		IF OBJECT_ID('tempdb..#tempProyectos') IS NOT NULL DROP TABLE #tempProyectos;
		IF OBJECT_ID('tempdb..#tempHistorialEstatusProyectos') IS NOT NULL DROP TABLE #tempHistorialEstatusProyectos;

		DECLARE
			@TotalPaginas INT = 0,
			@TotalRegistros DECIMAL(18,2) = 0.00;

		IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
		IF(ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

		SELECT
			@orderByColumn	= CASE WHEN @orderByColumn IS NULL THEN 'IDEstatus' ELSE @orderByColumn END,
			@orderDirection = CASE WHEN @orderDirection IS NULL THEN 'ASC' ELSE @orderDirection END

		SET @query = CASE
						WHEN @query IS NULL THEN '""'
						WHEN @query = '' THEN '""'
						WHEN @query = '""' THEN @query
					ELSE '"' + @query + '*"' END


		DECLARE @tempResponse AS TABLE (
			IDProyecto INT,
			Nombre VARCHAR(255),
			Descripcion VARCHAR(255),
			IDEstatus INT,
			Estatus VARCHAR(100),
			FechaCreacion DATETIME,
			Usuario VARCHAR(255),
			Progreso INT,
			FechaInicio VARCHAR(50)
		);

		SELECT TEP.IDEstatusProyecto,
			   TEP.IDProyecto,
			   ISNULL(TEP.IDEstatus, 0) AS IDEstatus,
			   ISNULL(ESTATUS.Estatus, 'Sin estatus') AS Estatus,
			   TEP.IDUsuario,
			   TEP.FechaCreacion,
			   ROW_NUMBER() OVER(PARTITION BY TEP.IDProyecto ORDER BY TEP.IDProyecto, TEP.FechaCreacion DESC) AS [ROW]
		INTO #tempHistorialEstatusProyectos
		from [Evaluacion360].[tblCatProyectos] TCP WITH (NOLOCK)
			LEFT JOIN [Evaluacion360].[tblEstatusProyectos] TEP WITH (NOLOCK) ON TEP.IDProyecto = TCP.IDProyecto
			LEFT JOIN (SELECT * FROM Evaluacion360.tblCatEstatus WITH (NOLOCK) WHERE IDTipoEstatus = 1) ESTATUS ON TEP.IDEstatus = ESTATUS.IDEstatus

		
		INSERT @tempResponse
		SELECT P.IDProyecto,
			   P.Nombre,
			   ISNULL(P.Descripcion, '') AS Descripcion,
			   ISNULL(THEP.IDEstatus, 0) AS IDEstatus,
			   ISNULL(THEP.Estatus, 'Sin estatus') AS Estatus,
			   ISNULL(P.FechaCreacion, GETDATE()) AS FechaCreacion,
			   Usuario = CASE	
							WHEN EMP.IDEmpleado IS NOT NULL 
								THEN COALESCE(EMP.Nombre, '') + ' ' + COALESCE(EMP.Paterno, '') + ' ' + COALESCE(EMP.Materno, '')
								ELSE COALESCE(U.Nombre, '') + ' ' + COALESCE(U.Apellido, '') 
							END,
			   ISNULL(P.Progreso, 0) AS Progreso,
			   ISNULL(P.FechaInicio, '1990-01-01') AS FechaInicio
		FROM [Evaluacion360].[tblCatProyectos] P WITH (NOLOCK)
			JOIN [Seguridad].[TblUsuarios] U WITH (NOLOCK) ON P.IDUsuario = u.IDUsuario
			JOIN [Evaluacion360].[tblWizardsUsuarios] WU WITH (NOLOCK) ON WU.IDProyecto = P.IDProyecto
			JOIN #tempHistorialEstatusProyectos THEP ON P.IDProyecto = THEP.IDProyecto AND THEP.[ROW] = 1
			LEFT JOIN [RH].[tblEmpleados] EMP WITH (NOLOCK) ON U.IDEmpleado = EMP.IDEmpleado
		WHERE THEP.IDEstatus IN (SELECT CAST(item AS INT) FROM App.Split(@IdsEstatus, ',')) AND
			  (@query = '""' OR CONTAINS(P.*, @query))
		ORDER BY P.Nombre ASC



		SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
		FROM @tempResponse

		SELECT @TotalRegistros = CAST(COUNT([IDProyecto]) AS DECIMAL(18,2)) FROM @tempResponse

		SELECT *,
			   TotalPages = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
			   CAST(@TotalRegistros AS INT) AS TotalRows
		FROM @tempResponse
		ORDER BY
			CASE WHEN @orderByColumn = 'IDEstatus'	and @orderDirection = 'asc'	THEN IDEstatus END,
			CASE WHEN @orderByColumn = 'IDEstatus'	and @orderDirection = 'desc' THEN IDEstatus END DESC,
			CASE WHEN @orderByColumn = 'IDProyecto'	and @orderDirection = 'asc'	THEN IDProyecto END,
			CASE WHEN @orderByColumn = 'IDProyecto'	and @orderDirection = 'desc' THEN IDProyecto END DESC,
			IDEstatus, IDProyecto
		OFFSET @PageSize * (@PageNumber - 1) ROWS
		FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
