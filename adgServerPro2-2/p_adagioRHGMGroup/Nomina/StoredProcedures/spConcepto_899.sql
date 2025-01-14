USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: (NF) DEDUCCIONES
** Autor			: Aneudy Abreu					| Jose Román,
** Email			: aneudy.abreu@adagio.com.mx	| jose.roman@adagio.com.mx
** FechaCreacion	: 2019-08-12
** Paremetros		:              
** Versión 1.2 

** DataTypes Relacionados: 
  @dtconfigs [Nomina].[dtConfiguracionNomina]  
  @dtempleados [RH].[dtEmpleados]  
  @dtConceptos [Nomina].[dtConceptos]  
  @dtPeriodo [Nomina].[dtPeriodos]  
  @dtDetallePeriodo [Nomina].[dtDetallePeriodo] 


  VARIABLES A REEMPLAZAR (SIN LOS ESPACIOS)

  {{ DescripcionConcepto }}
  {{ CodigoConcepto }}

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROC [Nomina].[spConcepto_899]
( @dtconfigs [Nomina].[dtConfiguracionNomina] READONLY 
 ,@dtempleados [RH].[dtEmpleados] READONLY 
 ,@dtConceptos [Nomina].[dtConceptos] READONLY 
 ,@dtPeriodo [Nomina].[dtPeriodos] READONLY 
 ,@dtDetallePeriodo [Nomina].[dtDetallePeriodo] READONLY) 
AS 
BEGIN 

	DECLARE 
		@ClaveEmpleado varchar(20) 
		,@IDEmpleado int 
		,@i int = 0 
		,@Codigo varchar(20) = '899' 
		,@IDConcepto int 
		,@dtDetallePeriodoLocal [Nomina].[dtDetallePeriodo] 
		,@IDPeriodo int 
		,@IDTipoNomina int 
		,@Ejercicio int 
		,@ClavePeriodo varchar(20) 
		,@DescripcionPeriodo	varchar(250) 
		,@FechaInicioPago date 
		,@FechaFinPago date 
		,@FechaInicioIncidencia date 
		,@FechaFinIncidencia	date 
		,@Dias int 
		,@AnioInicio bit 
		,@AnioFin bit 
		,@MesInicio bit 
		,@MesFin bit 
		,@IDMes int 
		,@BimestreInicio bit 
		,@BimestreFin bit 
		,@General bit 
		,@Finiquito bit 
		,@Especial bit 
		,@Cerrado bit 
		,@PeriodicidadPago Varchar(100)
		,@isPreviewFiniquito bit 
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
 
	DECLARE
		@Concepto_IDConcepto int
		,@Concepto_Codigo varchar(20)
		,@Concepto_Descripcion varchar(100)
		,@Concepto_IDTipoConcepto int
		,@Concepto_Estatus bit
		,@Concepto_Impresion bit
		,@Concepto_IDCalculo int
		,@Concepto_CuentaAbono varchar(50)
		,@Concepto_CuentaCargo  varchar(50)
		,@Concepto_bCantidadMonto bit
		,@Concepto_bCantidadDias bit
		,@Concepto_bCantidadVeces bit
		,@Concepto_bCantidadOtro1 bit
		,@Concepto_bCantidadOtro2 bit
		,@Concepto_IDCodigoSAT int
		,@Concepto_NombreProcedure varchar(200)
		,@Concepto_OrdenCalculo int
		,@Concepto_LFT bit
		,@Concepto_Personalizada bit
		,@Concepto_ConDoblePago bit;
		
		
	select top 1 
		@Concepto_IDConcepto = IDConcepto 
		,@Concepto_Codigo  = Codigo 
		,@Concepto_Descripcion = Descripcion
		,@Concepto_IDTipoConcepto = IDTipoConcepto 
		,@Concepto_Estatus = Estatus 
		,@Concepto_Impresion = Impresion 
		,@Concepto_IDCalculo = IDCalculo 
		,@Concepto_CuentaAbono = CuentaAbono 
		,@Concepto_CuentaCargo = CuentaCargo 
		,@Concepto_bCantidadMonto = bCantidadMonto
		,@Concepto_bCantidadDias = bCantidadDias
		,@Concepto_bCantidadVeces = bCantidadVeces
		,@Concepto_bCantidadOtro1 = bCantidadOtro1
		,@Concepto_bCantidadOtro2 = bCantidadOtro2 
		,@Concepto_IDCodigoSAT = IDCodigoSAT
		,@Concepto_NombreProcedure = NombreProcedure 
		,@Concepto_OrdenCalculo = OrdenCalculo
		,@Concepto_LFT = LFT
		,@Concepto_Personalizada = Personalizada 
		,@Concepto_ConDoblePago = ConDoblePago
	from @dtConceptos where Codigo=@Codigo;
		
	insert into @dtDetallePeriodoLocal 
	select * from @dtDetallePeriodo where IDConcepto=@IDConcepto 
 
 	select top 1 @isPreviewFiniquito = cast(isnull(valor,0) as bit) from @dtconfigs
	 where Configuracion = 'isPreviewFiniquito'

	select @PeriodicidadPago = PP.Descripcion from Nomina.tblCatTipoNomina TN
		Inner join [Sat].[tblCatPeriodicidadesPago] PP
			on TN.IDPEriodicidadPAgo = PP.IDPeriodicidadPago
	Where TN.IDTipoNomina = @IDTipoNomina
 	 /* @configs: Contiene todos los parametros de configuración de la nómina. */ 
 	 /* @empleados: Contiene todos los trabajadores a calcular.*/ 
 
	/* 
	Descomenta esta parte de código si necesitas recorrer la lista de trabajadores 
 
	select @i=min(RowNumber) from @dtempleados; 
 
	while exists(select 1 from @empleados where RowNumber >= @i) 
	begin 
 		select @IDEmpleado=IDEmpleado, @ClaveEmpleado=ClaveEmpleado from @dtempleados where RowNumber =@i; 
 		print @ClaveEmpleado 
 		select @i=min(RowNumber) from @empleados where RowNumber > @i; 
	end;  
	*/ 
 
/* if OBJECT_ID('tempdb..#tempDeduccionesFiscales') is not null  
    drop table #tempDeduccionesFiscales;  
  
  select e.IDEmpleado  
     ,dp.IDPeriodo  
     ,sum(dp.ImporteTotal1) as ImporteTotal1   
   into #tempDeduccionesFiscales    
  from   
    @dtempleados E  
    inner join   
   @dtDetallePeriodo DP  
    on E.IDEmpleado = dp.IDEmpleado  
    and DP.IDPeriodo = @IDPeriodo  
   inner join Nomina.tblCatConceptos c  
    on DP.IDConcepto = C.IDConcepto  
   Inner join Nomina.tblCatTipoConcepto TipoConcepto  
    on c.IDTipoConcepto = TipoConcepto.IDTipoConcepto  
     and TipoConcepto.Descripcion in( 'DEDUCCION')  
     and c.Codigo  not in ('301','301A','301B','301C', '384','385','302','303','311')  
	 and c.Estatus = 1
  GROUP BY e.IDEmpleado,dp.IDPeriodo  */
 
 ------------------------------------------------------------------------
   	 if OBJECT_ID('tempdb..#tempDeducciones') is not null  
    drop table #tempDeducciones;  

	select   e.IDEmpleado  
			,dp.IDPeriodo  
			,0 as ImporteGravado  
			,0 as ImporteExcento  
			,sum(dp.ImporteOtro) as ImporteOtro  
			,sum(dp.ImporteTotal1) /*+ ISNULL(DF.ImporteTotal1,0)*/ as ImporteTotal1  
			,sum(dp.ImporteTotal2) as ImporteTotal2  
	into #tempDeducciones    
	from   
		@dtempleados E  
		inner join @dtDetallePeriodo DP  
			on E.IDEmpleado = dp.IDEmpleado  
				and DP.IDPeriodo = @IDPeriodo  
		inner join @dtConceptos c  
			on DP.IDConcepto = C.IDConcepto and c.Estatus = 1 and (C.IDTipoConcepto = 2 or c.Codigo between '800' AND '898')
	where c.Codigo NOT IN ('301','301A','301B','301C','302','303','311','384','385','802','301F','399') and isnull(E.SalarioDiarioReal,0) > 0
	group by e.IDEmpleado,dp.IDPeriodo

	/*select   e.IDEmpleado  
			,dp.IDPeriodo  
			,sum(dp.ImporteGravado) as ImporteGravado  
			,sum(dp.ImporteExcento) as ImporteExcento  
			,sum(dp.ImporteOtro) as ImporteOtro  
			,sum(dp.ImporteTotal1) /*+ ISNULL(DF.ImporteTotal1,0)*/ as ImporteTotal1  
			,sum(dp.ImporteTotal2) as ImporteTotal2  
	into #tempDeducciones    
	from   
		@dtempleados E  
		inner join @dtDetallePeriodo DP  
			on E.IDEmpleado = dp.IDEmpleado  
				and DP.IDPeriodo = @IDPeriodo  
		inner join @dtConceptos c  
			on DP.IDConcepto = C.IDConcepto  
		Inner join Nomina.tblCatTipoConcepto TipoConcepto  
			on c.IDTipoConcepto = TipoConcepto.IDTipoConcepto  
		and TipoConcepto.Descripcion in('INFORMATIVO')  
			and c.Estatus = 1 and c.Codigo between '800' AND '898'
		/*Inner Join #tempDeduccionesFiscales DF
			on DF.IDEmpleado = e.IDEmpleado
				and DF.IDPeriodo = @IDPeriodo*/
	GROUP BY e.IDEmpleado,dp.IDPeriodo */ 

	
   
   MERGE @dtDetallePeriodoLocal AS TARGET  
      USING #tempDeducciones AS SOURCE  
      ON TARGET.IDPeriodo = SOURCE.IDPeriodo  
        and TARGET.IDConcepto = @IDConcepto  
        and TARGET.IDEmpleado = SOURCE.IDEmpleado  
      WHEN MATCHED Then  
      update  
      Set       
      TARGET.ImporteGravado  = SOURCE.ImporteGravado  
      ,TARGET.ImporteExcento  = SOURCE.ImporteExcento  
      ,TARGET.ImporteOtro  = SOURCE.ImporteOtro  
      ,TARGET.ImporteTotal1  = SOURCE.ImporteTotal1  
      ,TARGET.ImporteTotal2  = SOURCE.ImporteTotal2  
      WHEN NOT MATCHED BY TARGET THEN   
      INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteGravado,ImporteExcento,ImporteOtro,ImporteTotal1,ImporteTotal2)  
      VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,@IDConcepto,Source.ImporteGravado,Source.ImporteExcento,Source.ImporteOtro,Source.ImporteTotal1,Source.ImporteTotal2)  
     WHEN NOT MATCHED BY SOURCE THEN   
     DELETE;   

	Select * from @dtDetallePeriodoLocal  
 	where 
		(isnull(CantidadMonto,0)+		 
		isnull(CantidadDias,0)+		 
		isnull(CantidadVeces,0)+		 
		isnull(CantidadOtro1,0)+		 
		isnull(CantidadOtro2,0)+		 
		isnull(ImporteGravado,0)+		 
		isnull(ImporteExcento,0)+		 
		isnull(ImporteOtro,0)+		 
		isnull(ImporteTotal1,0)+		 
		isnull(ImporteTotal2,0) ) > 0	 
END;
GO
