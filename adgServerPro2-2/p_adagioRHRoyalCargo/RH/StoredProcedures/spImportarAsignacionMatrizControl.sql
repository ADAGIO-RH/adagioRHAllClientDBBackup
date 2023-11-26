USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Asignacion de controles de acceso a la plaza
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2023-08-03
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
create   proc [RH].[spImportarAsignacionMatrizControl](			
    @dtImportacion [RH].[dtImportacionAsignacionControlAcceso] readonly	,
	@IDUsuario int
) as 

    if object_id('tempdb..#tempImportacionMatrizControlAcceso') is not null drop table #tempImportacionMatrizControlAcceso;
    Create table #tempImportacionMatrizControlAcceso   (      
            IDEmpleado int,        
            IDMatrizControlAcceso int,
            Value bit
    );     

    insert into #tempImportacionMatrizControlAcceso
    select m.IDEmpleado,IDMatrizControlAcceso ,Value from @dtImportacion i
    inner join rh.tblEmpleadosMaster m on m.ClaveEmpleado=i.ClaveEmpleado

    
    MERGE [RH].[tblAsignacionesMatrizControlAcceso] AS TARGET
    USING #tempImportacionMatrizControlAcceso as SOURCE
    on TARGET.IDMatrizControlAcceso = SOURCE.IDMatrizControlAcceso
    and TARGET.IDEmpleado = SOURCE.IDEmpleado            
    WHEN MATCHED THEN
        update
            set
            TARGET.Value = SOURCE.Value            
    WHEN NOT MATCHED BY TARGET THEN
        INSERT(IDMatrizControlAcceso,IDEmpleado,Value)
        values(SOURCE.IDMatrizControlAcceso,SOURCE.IDEmpleado,SOURCE.Value)
    OUTPUT $action;
GO
