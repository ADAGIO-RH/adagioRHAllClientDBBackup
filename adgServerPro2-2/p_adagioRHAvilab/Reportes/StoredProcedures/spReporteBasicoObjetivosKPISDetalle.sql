USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Reportes].[spReporteBasicoObjetivosKPISDetalle](
	
	 @IDEmpleado int
    ,@IDCicloMedicionObjetivo int
	,@IDUsuario int

) as
	SET FMTONLY OFF;  

	-- declare  
	-- 	@IDIdioma varchar(20)
	-- 	,@IDJefe int

	-- ;
    DECLARE 
    @IDIdioma varchar(20)
    
	

	-- select @IDJefe = IDEmpleado
	-- from Seguridad.tblUsuarios
	-- where IDUsuario = @IDUsuario

	


	--IF OBJECT_ID('tempdb..#TempObjetivosEmpleados') IS NOT NULL DROP TABLE #TempObjetivosEmpleados; 

	select 
		 oe.IDObjetivoEmpleado
		,oe.IDObjetivo
        ,o.Nombre
		,o.Descripcion as DescripcionObjetivo
		,o.IDTipoMedicionObjetivo 
		,oe.IDEmpleado
		,oe.Objetivo
		,oe.Actual
		,oe.Peso
		,oe.PorcentajeAlcanzado
		,oe.IDEstatusObjetivoEmpleado
		-- ,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as NombreEO
		-- ,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as DescripcionEO
		,oe.IDUsuario
        --,oe.UltimaActualizacion
        ,convert(varchar,oe.UltimaActualizacion, 103) as UltimaActualizacion
		,oe.FechaHoraReg
        ,CicloMedicion.Nombre as CicloMedicion
	from Evaluacion360.tblObjetivosEmpleados oe
		INNER JOIN Evaluacion360.tblCatEstatusObjetivosEmpleado eo
            on eo.IDEstatusObjetivoEmpleado = oe.IDEstatusObjetivoEmpleado
        INNER JOIN Evaluacion360.tblCatObjetivos o 
            on o.IDObjetivo = oe.IDObjetivo    
        INNER JOIN Evaluacion360.tblCatCiclosMedicionObjetivos CicloMedicion
            on CicloMedicion.IDCicloMedicionObjetivo=o.IDCicloMedicionObjetivo    
	where (o.IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo or isnull(@IDCicloMedicionObjetivo, 0) = 0) AND oe.IDEmpleado=@IDEmpleado

--     SELECT 
--     DISTINCT(empleados.ClaveEmpleado)
--    ,empleados.NOMBRECOMPLETO
--     ,(
--             SELECT TOP 1 CONCAT(E.NOMBRECOMPLETO,' ',E.ClaveEmpleado)
--             FROM RH.tblJefesEmpleados JE
--                 INNER JOIN RH.tblEmpleadosMaster E
--                 ON JE.IDJefe=E.IDEmpleado
--                 WHERE empleados.IDEmpleado=JE.IDEmpleado
--                 ORDER BY IDJefeEmpleado DESC
--     ) AS NombreClaveJefe
--     ,CMO.Nombre AS CicloMedicion
--     ,empleados.Departamento
    
--     FROM @dtEmpleados empleados
--         INNER JOIN Evaluacion360.tblObjetivosEmpleados OE
--             ON OE.IDEmpleado=empleados.IDEmpleado
--         INNER JOIN Evaluacion360.tblCatObjetivos O
--             ON O.IDObjetivo=OE.IDObjetivo
--         INNER JOIN Evaluacion360.tblCatCiclosMedicionObjetivos CMO
--             ON CMO.IDCicloMedicionObjetivo=O.IDCicloMedicionObjetivo
--     WHERE (O.IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo or isnull(@IDCicloMedicionObjetivo, 0) = 0)
GO
