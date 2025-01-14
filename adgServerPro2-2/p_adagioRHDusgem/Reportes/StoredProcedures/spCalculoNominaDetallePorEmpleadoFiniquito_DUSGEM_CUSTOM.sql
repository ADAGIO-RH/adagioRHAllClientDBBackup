USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spCalculoNominaDetallePorEmpleadoFiniquito_DUSGEM_CUSTOM]--4114,17,'5'      
(      
 @IDEmpleado int,      
 @IDPeriodo int,          
 @Codigo varchar(max) = null,
 @IDFiniquito int,   
 @IDTipoConcepto varchar(50)
)      
AS      
BEGIN      
    SET NOCOUNT ON;  
     IF 1=0 BEGIN  
       SET FMTONLY OFF  
     END  

	DECLARE
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

       
 IF OBJECT_ID('tempdb..#tempResultado') IS NOT NULL      
  DROP TABLE #tempResultado    
  
  IF OBJECT_ID('tempdb..#tempResultadoFiniquito') IS NOT NULL      
  DROP TABLE #tempResultadoFiniquito    
 
 declare 
	 @Estatus varchar(max)
	,@CodigosConceptosFiscales varchar(max);
	

 select top 1 @Estatus = ef.Descripcion from Nomina.tblControlFiniquitos cf
	inner join Nomina.tblCatEstatusFiniquito ef
		on cf.IDEStatusFiniquito = ef.IDEStatusFiniquito
 where IDFiniquito = @IDFiniquito  


 SELECT @CodigosConceptosFiscales = STRING_AGG(Codigo,',') WITHIN GROUP(ORDER BY OrdenCalculo)
 FROM Nomina.tblCatConceptos WITH (NOLOCK) 
 WHERE IDTipoConcepto IN (SELECT CAST(Item AS int) FROM App.Split(@IDTipoConcepto,','))
 AND Impresion = 1 AND Estatus = 1


 if(@Estatus = 'Aplicar')
 BEGIN
 
      
      
	   select dp.IDPeriodo      
		,cp.Descripcion as Periodo      
		,cp.IDTipoNomina as IDTipoNomina      
		,tn.Descripcion as TipoNomina      
		,tn.IDCliente as IDCliente      
		,JSON_VALUE(cc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente      
		,tn.IDPeriodicidadPago as IDPeriodicidadPago      
		,pp.Descripcion as PeriodicidadPago      
		,dp.IDConcepto      
		,ccp.Codigo      
		,ccp.Descripcion as Concepto      
		,ccp.IDTipoConcepto      
		,tc.Descripcion as TipoConcepto      
		,ccp.OrdenCalculo      
		,case when dp.idconcepto in (17,18,24) then null
			  when dp.descripcion = '' then null
		 else REPLACE(REPLACE(dp.Descripcion,'Dia(s)',''),'Hora(s)','') end AS Descripcion      
		,dp.CantidadMonto as CantidadMonto      
		,dp.CantidadDias as CantidadDias      
		,dp.CantidadVeces as CantidadVeces      
		,dp.CantidadOtro1 as CantidadOtro1      
		,dp.CantidadOtro2 as CantidadOtro2      
		,dp.ImporteGravado as ImporteGravado      
		,dp.ImporteExcento as ImporteExcento      
		,dp.ImporteOtro as ImporteOtro      
		,dp.ImporteTotal1 as ImporteTotal1      
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
	 where cp.IDPeriodo = @IDPeriodo           
	 and dp.IDEmpleado = @IDEmpleado            
	 and (ccp.Codigo in ( SELECT Codigo FROM Nomina.tblCatConceptos WHERE Codigo BETWEEN '700' AND '999' AND Estatus = 1
						  UNION ALL 
						  SELECT Codigo FROM Nomina.tblCatConceptos WHERE Codigo BETWEEN 'A700' AND 'A999' AND Estatus = 1
						  UNION ALL 
						  SELECT Item FROM App.Split(@CodigosConceptosFiscales,',')
						))
	 and  dp.ImporteTotal1 <> 0
	 ORDER BY ccp.OrdenCalculo ASC    
     
	  SELECT * FROM #tempResultado      
	  WHERE Codigo IN (SELECT Item FROM App.Split(@Codigo,',')) 
	  UNION ALL
	  SELECT * FROM #tempResultado      
	  WHERE IDTipoConcepto IN (SELECT CAST(Item AS INT) FROM App.Split(@IDTipoConcepto,','))
	  ORDER BY OrdenCalculo ASC    
	   
	  DROP TABLE #tempResultado;      
 
 END
 ELSE
 BEGIN
		select dp.IDPeriodo      
		,cp.Descripcion as Periodo      
		,cp.IDTipoNomina as IDTipoNomina      
		,tn.Descripcion as TipoNomina      
		,tn.IDCliente as IDCliente      
		,JSON_VALUE(cc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente      
		,tn.IDPeriodicidadPago as IDPeriodicidadPago      
		,pp.Descripcion as PeriodicidadPago      
		,dp.IDConcepto      
		,ccp.Codigo      
		,ccp.Descripcion as Concepto      
		,ccp.IDTipoConcepto      
		,tc.Descripcion as TipoConcepto      
		,ccp.OrdenCalculo      
		,case when dp.idconcepto in (17,18,24) then null else REPLACE(REPLACE(dp.Descripcion,'Dia(s)',''),'Hora(s)','') end AS Descripcion            
		,dp.CantidadMonto as CantidadMonto      
		,dp.CantidadDias as CantidadDias      
		,dp.CantidadVeces as CantidadVeces      
		,dp.CantidadOtro1 as CantidadOtro1      
		,dp.CantidadOtro2 as CantidadOtro2      
		,dp.ImporteGravado as ImporteGravado      
		,dp.ImporteExcento as ImporteExcento      
		,dp.ImporteOtro as ImporteOtro      
		,dp.ImporteTotal1 as ImporteTotal1      
		,dp.ImporteTotal2 ImporteTotal2          
		,dp.ImporteAcumuladoTotales as ImporteAcumuladoTotales      
	 INTO #tempResultadoFiniquito      
	   from [Nomina].[tblDetallePeriodoFiniquito] dp with (nolock)      
		LEFT join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo      
	 LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina      
	 LEFT join [RH].[tblCatClientes] cc with (nolock) on cc.IDCliente = tn.IDCliente      
	 LEFT join [Sat].[tblCatPeriodicidadesPago] pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago      
		INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto         
	 INNER join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto      
	 where cp.IDPeriodo = @IDPeriodo    
	 and dp.IDEmpleado = @IDEmpleado          
	 and (ccp.Codigo in ( SELECT Codigo FROM Nomina.tblCatConceptos WHERE Codigo BETWEEN '700' AND '999' AND Estatus = 1
						  UNION ALL 
						  SELECT Codigo FROM Nomina.tblCatConceptos WHERE Codigo BETWEEN 'A700' AND 'A999' AND Estatus = 1
						  UNION ALL 
						  SELECT Item FROM App.Split(@CodigosConceptosFiscales,',')
						))
	 and  dp.ImporteTotal1 <> 0
	 ORDER BY ccp.OrdenCalculo ASC     
	   
	  SELECT * FROM #tempResultadoFiniquito      
	  WHERE Codigo IN (SELECT Item FROM App.Split(@Codigo,',')) 
	  UNION ALL
	  SELECT * FROM #tempResultadoFiniquito      
	  WHERE IDTipoConcepto IN (SELECT CAST(Item AS INT) FROM App.Split(@IDTipoConcepto,','))
	  ORDER BY OrdenCalculo ASC      
	  
	  DROP TABLE #tempResultadoFiniquito;   
	  
      END
END
GO
