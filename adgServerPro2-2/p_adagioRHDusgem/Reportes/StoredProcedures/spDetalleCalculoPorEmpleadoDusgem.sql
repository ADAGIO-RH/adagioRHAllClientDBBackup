USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spDetalleCalculoPorEmpleadoDusgem](    

	 @IDEmpleado INT    
	,@IDPeriodo INT  
	,@IDTipoConcepto VARCHAR(50) = NULL    
	,@Codigo VARCHAR(MAX) = NULL      

)    
AS    

BEGIN   

    SET NOCOUNT ON;
    
	IF 1=0 
	BEGIN
       SET FMTONLY OFF
    END;

     
	DECLARE
		@Asimilado BIT 
	   ,@ConceptosComplemento VARCHAR(MAX)
	;


	SELECT @Asimilado = Asimilados FROM Nomina.tblCatTipoNomina WHERE IDTipoNomina IN (SELECT IDTipoNomina FROM Nomina.tblCatPeriodos WHERE IDPeriodo = @IDPeriodo)

	SELECT @ConceptosComplemento = (SELECT STRING_AGG(Codigo,',') FROM ( SELECT Codigo FROM Nomina.tblCatConceptos WHERE Codigo BETWEEN '700' AND '999'
																		 UNION ALL 
																		 SELECT Codigo FROM Nomina.tblCatConceptos WHERE Codigo BETWEEN 'A700' AND 'A999'
																	    ) X )


	IF OBJECT_ID('TempDB..#TempResultado') IS NOT NULL DROP TABLE #TempResultado;    
	IF OBJECT_ID('TempDB..#TempComplemento') IS NOT NULL DROP TABLE #TempComplemento;

    
	SELECT 
		 dp.IDPeriodo   
		,dp.IDEmpleado 
		,cp.IDTipoNomina as IDTipoNomina 
		,dp.IDConcepto    
		,ccp.Codigo    
		,ccp.Descripcion as Concepto    
		,ccp.IDTipoConcepto    
		,tc.Descripcion as TipoConcepto    
		,ccp.OrdenCalculo    
		,ccp.Impresion
		,dp.Descripcion   
		,dp.ImporteTotal1 as ImporteTotal1    
	INTO #tempResultado    
	from [Nomina].[tblDetallePeriodo] dp with (nolock)    
		LEFT join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo            
		INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto       
		INNER join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto    
	where cp.IDPeriodo = @IDPeriodo    
		and ccp.Impresion = 1    
		and dp.IDEmpleado = @IDEmpleado    
		and ((tc.IDTipoConcepto in (select ITEM from App.Split(@IDTipoConcepto,','))) OR (isnull(@IDTipoConcepto,'') = ''))  
		and ((ccp.Codigo in (select ITEM from App.Split(@Codigo,','))) OR (isnull(@Codigo,'') = ''))    
		and (ccp.Codigo not in (Select Item FROM App.Split(@ConceptosComplemento,',')))     
	ORDER BY ccp.OrdenCalculo ASC    


	UPDATE #TempResultado
		SET Descripcion = NULL
	WHERE (Descripcion = '' OR IDConcepto IN (17,18))


	select 
		 dp.IDPeriodo   
		,dp.IDEmpleado 
		,cp.IDTipoNomina as IDTipoNomina 
		,dp.IDConcepto    
		,ccp.Codigo    
		,ccp.Descripcion as Concepto    
		,ccp.IDTipoConcepto    
		,tc.Descripcion as TipoConcepto    
		,ccp.OrdenCalculo    
		,ccp.Impresion
		,NULL AS Descripcion   
		,dp.ImporteTotal1 as ImporteTotal1    
		,CAST(0 AS INT) AS IDConceptoEmpatado
	INTO #tempComplemento    
	from [Nomina].[tblDetallePeriodo] dp with (nolock)    
		LEFT join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo     
		INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto       
		INNER join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto    
	where cp.IDPeriodo = @IDPeriodo  
		and dp.IDEmpleado = @IDEmpleado    
		and (ccp.Codigo in (Select Item FROM App.Split(@ConceptosComplemento,',')))    
	ORDER BY ccp.OrdenCalculo ASC


	UPDATE #TempComplemento
		SET IDConceptoEmpatado = [Nomina].[fnEmpatarConceptosFiscal_Complemento](Codigo)


	UPDATE T
		SET T.IDConcepto = C.IDConcepto
		   ,T.Codigo = C.Codigo
		   ,T.Concepto = C.Descripcion
		   ,T.IDTipoConcepto = C.IDTipoConcepto
		   ,T.TipoConcepto = TC.Descripcion
		   ,T.OrdenCalculo = C.OrdenCalculo
		   ,T.Impresion = C.Impresion
	FROM #TempComplemento T
		INNER JOIN Nomina.tblCatConceptos C
			ON C.IDConcepto = T.IDConceptoEmpatado
		INNER JOIN Nomina.tblCatTipoConcepto TC
			ON TC.IDTipoConcepto = C.IDTipoConcepto

			
	IF (@Asimilado = 1)
	BEGIN

		UPDATE #TempComplemento
			SET IDTipoConcepto = CASE WHEN Codigo = 'A801' THEN 8
								 ELSE IDTipoConcepto
								 END

		UPDATE #TempResultado
			SET ImporteTotal1 = ImporteTotal1 + ISNULL((SELECT ImporteTotal1 FROM #TempComplemento WHERE Codigo = 'A801'),0)
		WHERE Codigo = 'A560'

	END


	IF (@IDTipoConcepto <> '')
	BEGIN
		DELETE FROM #TempComplemento WHERE IDTipoConcepto NOT IN (SELECT CAST(Item AS INT) FROM App.Split(@IDTipoConcepto,','))
	END;


	IF (@Codigo <> '')
	BEGIN	
		DELETE FROM #TempComplemento WHERE Codigo NOT IN (SELECT Item FROM App.Split(@Codigo,','))
	END;

	
	MERGE #TempResultado AS TARGET
	USING #TempComplemento AS SOURCE
		ON TARGET.IDPeriodo = SOURCE.IDPeriodo
		AND TARGET.IDEmpleado = SOURCE.IDEmpleado
		AND TARGET.IDConcepto = SOURCE.IDConcepto
	WHEN MATCHED THEN
		UPDATE 
			SET TARGET.ImporteTotal1 = /*ISNULL(TARGET.ImporteTotal1,0) +*/ ISNULL(SOURCE.ImporteTotal1,0)
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (IDEmpleado,IDperiodo,IDTipoNomina,IDConcepto,Codigo,Concepto,IDTipoConcepto,TipoConcepto,OrdenCalculo,Impresion,Descripcion,ImporteTotal1)
		VALUES (SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDTipoNomina,SOURCE.IDConcepto,SOURCE.Codigo,SOURCE.Concepto,SOURCE.IDTipoConcepto,SOURCE.TipoConcepto,SOURCE.OrdenCalculo,SOURCE.Impresion,SOURCE.Descripcion,ISNULL(SOURCE.ImporteTotal1,0))
	;


	IF(@IDTipoConcepto = '5')    
	BEGIN    
		SELECT * FROM #TempResultado  
		WHERE ImporteTotal1 > 0    
		ORDER BY OrdenCalculo ASC  
	END    
	ELSE    
	BEGIN    
		SELECT * FROM #TempResultado   
		WHERE ImporteTotal1 > 0    
		ORDER BY OrdenCalculo ASC 
	END 
	
	DROP TABLE #TempResultado;

END
GO
