USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE proc [Norma035].[spBuscarTiposEncuestas](
	 @IDTipoEncuesta int = 0

) as

SELECT [IDTipoEncuesta]
      ,[Descripcion]
      ,[Estatus]
      ,[UltimaActualizacion]
  FROM [Norma035].[tblCatTiposEncuestas]
  WHERE (IDTipoEncuesta = @IDTipoEncuesta or @IDTipoEncuesta = 0)
GO
