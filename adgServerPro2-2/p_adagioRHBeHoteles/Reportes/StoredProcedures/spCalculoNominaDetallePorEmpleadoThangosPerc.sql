USE [p_adagioRHBeHoteles]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spCalculoNominaDetallePorEmpleadoThangosPerc]--4114,17,'5'    
(    
 @IDEmpleado int,    
 @IDPeriodo int,    
 @IDTipoConcepto varchar(50),    
 @Codigo varchar(50) = null    
)    
AS    
BEGIN    
    SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END
     
	IF OBJECT_ID('tempdb..#tempResultado') IS NOT NULL DROP TABLE #tempResultado    
	if object_id('tempdb..#temporal1') is not null DROP TABLE #temporal1 

	select 
		dp.IDEmpleado as IDEmpleado
		,SUM (ISNULL (dp.ImporteTotal1,0)) as ImporteTotalResta 
	into #temporal1
	from nomina.tblDetallePeriodo dp
		LEFT join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo
		inner join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto  
	where (ccp.IDConcepto in ('145'))  and dp.idPeriodo = @IDPeriodo
	group by dp.IDEmpleado
    
    
	select dp.IDPeriodo    
		,cp.Descripcion as Periodo    
		,cp.IDTipoNomina as IDTipoNomina    
		,tn.Descripcion as TipoNomina    
		,tn.IDCliente as IDCliente    
		,cc.NombreComercial as Cliente    
		,tn.IDPeriodicidadPago as IDPeriodicidadPago    
		,pp.Descripcion as PeriodicidadPago    
		,dp.IDConcepto    
		,ccp.Codigo    
		,ccp.Descripcion as Concepto    
		,ccp.IDTipoConcepto    
		,tc.Descripcion as TipoConcepto    
		,ccp.OrdenCalculo    
		,dp.Descripcion    
		,dp.CantidadMonto as CantidadMonto    
		,dp.CantidadDias as CantidadDias    
		,dp.CantidadVeces as CantidadVeces    
		,dp.CantidadOtro1 as CantidadOtro1    
		,dp.CantidadOtro2 as CantidadOtro2    
		,dp.ImporteGravado as ImporteGravado    
		,dp.ImporteExcento as ImporteExcento    
		,dp.ImporteOtro as ImporteOtro  
		,case when t.ImporteTotalResta is not null  or t.ImporteTotalResta > 0 then   
		dp.ImporteTotal1 - ISNULL (t.ImporteTotalResta,0)
		else dp.ImporteTotal1 End as ImporteTotal1    
		,dp.ImporteTotal2 ImporteTotal2        
		,dp.ImporteAcumuladoTotales as ImporteAcumuladoTotales    
	INTO #tempResultado    
	from [Nomina].[tblDetallePeriodo] dp with (nolock)    
		LEFT join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo    
		LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina    
		LEFT join [RH].[tblCatClientes] cc with (nolock) on cc.IDCliente = tn.IDCliente    
		LEFT join [Sat].[tblCatPeriodicidadesPago] pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago    
		INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto       
		INNER join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto    
		inner join #temporal1 t on t.IDEmpleado = dp.IDEmpleado
	where cp.IDPeriodo = @IDPeriodo    
		and ccp.Impresion = 1    
		and dp.IDEmpleado = @IDEmpleado    
		and (tc.IDTipoConcepto in (select ITEM from App.Split(@IDTipoConcepto,',')))    
		and ((ccp.Codigo = @Codigo) OR (ISNULL(@Codigo,'') = '') )    
	ORDER BY ccp.OrdenCalculo ASC    
    
 --select * from #tempResultado    
    
	IF(@IDTipoConcepto = '5')    
	BEGIN    
		SELECT * FROM #tempResultado    
		WHERE ImporteTotal1 > 0    
	ORDER BY OrdenCalculo ASC  
	END    
	ELSE    
	BEGIN    
		SELECT * FROM #tempResultado   
		WHERE ImporteTotal1 > 0    
		
		ORDER BY OrdenCalculo ASC  
	END 
	
	DROP TABLE #tempResultado;
END
GO
