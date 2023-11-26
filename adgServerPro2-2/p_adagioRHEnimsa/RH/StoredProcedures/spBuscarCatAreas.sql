USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatAreas]
(
	@Area Varchar(50) = null
)
AS
BEGIN
	SELECT 
	IDArea
	,Codigo
	,Descripcion
	,CuentaContable
	,isnull(IDEmpleado,0) as IDEmpleado
	,JefeArea 
	FROM RH.tblCatArea
	WHERE (Codigo LIKE @Area+'%') OR(Descripcion LIKE @Area+'%') OR (@Area IS NULL)
	order by RH.tblCatArea.Descripcion asc

END
GO
