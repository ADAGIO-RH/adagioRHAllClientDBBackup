USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Buscar el acumulado por colaborador y conceptos por lista de periodos.  
** Autor   : Aneudy Abreu  
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2021-05-25  
** Paremetros  :                
  
** DataTypes Relacionados:   
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/  
create FUNCTION [Nomina].[fnObtenerAcumuladoRangoListaPeriodos]  
(
	@IDEmpleado int,  
	@CodigosConceptos varchar(max),  
	@IdsPeriodos varchar(max)
)  
RETURNS @tblAcumuladoPorConcepto TABLE   
(  
	-- Columns returned by the function  
	IDEmpleado int NOT NULL,   
	IDConcepto int NULL,   
	Ejercicio int NULL,   
	ImporteGravado Decimal(18,2)NULL,   
	ImporteExento Decimal(18,2)NULL,   
	ImporteTotal1 Decimal(18,2)NULL,   
	ImporteTotal2 Decimal(18,2)NULL    
)  
AS   
BEGIN  
	insert into @tblAcumuladoPorConcepto(IDEmpleado,IDConcepto,Ejercicio,ImporteGravado,ImporteExento,ImporteTotal1,ImporteTotal2)  
	Select @IDEmpleado as IDEmpleado,  
		DP.IDConcepto,  
		0 Ejercicio,  
		ISNULL(SUM(DP.ImporteGravado),0) as  ImporteGravado,  
		ISNULL(SUM(DP.ImporteExcento),0) as  ImporteExcento,  
		ISNULL(SUM(DP.ImporteTotal1),0) as  ImporteTotal1,  
		ISNULL(SUM(DP.ImporteTotal2),0) as  ImporteTotal2  
	from Nomina.tblDetallePeriodo DP  
		Inner join Nomina.tblCatPeriodos P on DP.IDPeriodo = P.IDPeriodo AND DP.IDEmpleado = @IDEmpleado AND P.Cerrado = 1  
		Inner join Nomina.tblCatConceptos c on dp.IDConcepto = c.IDConcepto  
	where c.Codigo in (select item from app.Split(@CodigosConceptos,','))  
		and p.IDPeriodo in (select cast(item as int) from app.Split(@IdsPeriodos,','))
	group by  DP.IDConcepto  
 RETURN;  
END
GO
