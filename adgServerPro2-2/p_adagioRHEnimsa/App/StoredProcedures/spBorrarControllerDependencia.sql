USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE App.spBorrarControllerDependencia
(
	@IDControllerParent int,
	@IDControllerChild int
)
AS
BEGIN
	Select 
	CD.IDControllerParent
	,c1.Nombre ControllerParent
	,CD.IDControllerChild
	,c2.Nombre ControllerChild
	,cd.IDTipoPermiso
	,p.Descripcion TipoPermiso
from app.TblControllerDependencias CD
	inner join App.tblCatControllers c1
		on CD.IDControllerParent = c1.IDController
	inner join App.tblCatControllers c2
		on cd.IDControllerChild = c2.IDController
	inner join app.tblCatTipoPermiso p
		on cd.IDTipoPermiso = p.IDTipoPermiso
 WHERE CD.IDControllerParent = @IDControllerParent
	and CD.IDControllerChild = @IDControllerChild

	Delete app.TblControllerDependencias
	WHERE IDControllerParent = @IDControllerParent
	and IDControllerChild = @IDControllerChild 

END
GO
