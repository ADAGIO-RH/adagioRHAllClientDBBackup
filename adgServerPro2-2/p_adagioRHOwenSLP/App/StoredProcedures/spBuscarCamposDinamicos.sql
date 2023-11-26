USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca campos dinamicos
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2022-08-22
** Paremetros		: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2022-12-12			Alejandro Paredes	Se agregaron los campos IDCampo, AliasCampo, GrupoCampo
***************************************************************************************************/

CREATE PROCEDURE [App].[spBuscarCamposDinamicos]
    @IDUsuario INT,
    @Grupo VARCHAR(100) = NULL
AS
	BEGIN
    
		DECLARE @IDIdioma VARCHAR(225);
		SELECT @IDIdioma = [APP].[fnGetPreferencia]('Idioma', @IDUsuario, 'esmx');

		SELECT IDCampoDinamico,
			   Campo,
			   Tabla,
			   JSON_VALUE(sP.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-', '')), 'Descripcion')) AS Descripcion,
			   --IDCampo,
			   AliasCampo,
			   GrupoCampo
		 FROM [APP].[tblCatCamposDinamicos] SP		
		 WHERE GrupoCampo IN(SELECT item FROM [APP].[Split](@Grupo, ',')) OR 
			   @Grupo IS NULL
		 ORDER BY IDCampoDinamico
    
	END
GO
