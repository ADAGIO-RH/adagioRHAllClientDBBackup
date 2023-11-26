USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-02-15
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROCEDURE [Transporte].[spBuscarCatMarcaVehiculos]
(
	@IDMarcaVehiculo int = null
)
AS
BEGIN
	SELECT  *
	FROM [Transporte].[tblCatMarcaVehiculos] TJ
		
	WHERE (tj.IDMarcaVehiculo = @IDMarcaVehiculo)  or (@IDMarcaVehiculo is null or @IDMarcaVehiculo =0)		
END
GO
