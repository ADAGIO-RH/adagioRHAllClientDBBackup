USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Regresa las fuentes de datos en base a la aplicacion
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-04-21
** Parametros		: @IDAplicacion
** IDAzure			: 814

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spRDataSources]
(
	@IDTipoItem INT,
	@IDAplicacion VARCHAR(100) = '',
	@IDTipoKpi INT
)
AS
	BEGIN		
		
		DECLARE @TipoKpi INT = 3;

		IF(@IDTipoItem = @TipoKpi)
			BEGIN
				
				SELECT D.IDDataSource,
					   D.Nombre
				FROM [InfoDir].[tblCatDataSource] D
				WHERE D.IDTipoItem = @IDTipoItem AND 
					  D.IDAplicacion = @IDAplicacion AND
					  D.IDTipoKpi = @IDTipoKpi

			END
		ELSE
			BEGIN
				
				SELECT D.IDDataSource,
					   D.Nombre
				FROM [InfoDir].[tblCatDataSource] D
				WHERE D.IDTipoItem = @IDTipoItem AND 
					  D.IDAplicacion = @IDAplicacion

			END

	END
GO
