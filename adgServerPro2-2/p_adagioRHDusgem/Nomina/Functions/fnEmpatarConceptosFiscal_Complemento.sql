USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Nomina].[fnEmpatarConceptosFiscal_Complemento](

	@Codigo VARCHAR(20)

)
RETURNS INT 
AS

BEGIN

	DECLARE 
		 @IDConceptoEmpatado INT
		,@ConceptosComplemento VARCHAR(MAX)


	SELECT @ConceptosComplemento = (SELECT STRING_AGG(Codigo,',') FROM ( SELECT Codigo FROM Nomina.tblCatConceptos WHERE Codigo BETWEEN '700' AND '999'
																		 UNION ALL 
																		 SELECT Codigo FROM Nomina.tblCatConceptos WHERE Codigo BETWEEN 'A700' AND 'A999'
																	    ) X )


	IF (@Codigo NOT IN (SELECT Item FROM App.Split(@ConceptosComplemento,',')) )
	BEGIN
		RETURN 0;
	END


	SET @IDConceptoEmpatado = CASE WHEN @Codigo = '701'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '101')
								   WHEN @Codigo = '702'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '102')
								   WHEN @Codigo = '710'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '110')
								   WHEN @Codigo = '711'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '111')
								   WHEN @Codigo = '721'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '141')
								   WHEN @Codigo = '722'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '135')
								   WHEN @Codigo = '723'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '137')
								   WHEN @Codigo = '724'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '136')
								   WHEN @Codigo = '725'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '147')
								   WHEN @Codigo = '726'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '121')
								   WHEN @Codigo = '727'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '144')
								   WHEN @Codigo = '728'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '120')
								   WHEN @Codigo = '729'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '130')
								   WHEN @Codigo = '730'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '108')
								   WHEN @Codigo = '799'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '550')
								   WHEN @Codigo = '801'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '302')
								   WHEN @Codigo = '802'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '301')
								   WHEN @Codigo = '803'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '313')
								   WHEN @Codigo = '804'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '314')
								   WHEN @Codigo = '805'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '304')
								   WHEN @Codigo = '806'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '323')
								   WHEN @Codigo = '807'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '326')
								   WHEN @Codigo = '899'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '560')
								   --WHEN @Codigo = '900'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '')
								   WHEN @Codigo = '901'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '601')
								   --WHEN @Codigo = '902'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '')
								   --WHEN @Codigo = '903'  THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '')
								   --WHEN @Codigo = 'A801' THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = '')
								   WHEN @Codigo = 'A902' THEN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = 'A601')
							  END


	RETURN @IDConceptoEmpatado


END
GO
