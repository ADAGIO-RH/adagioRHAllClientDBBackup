USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE App.spBuscarTipoPermiso
AS
select 
	IDTipoPermiso
	,Prioridad
	,Hologacion
	,Descripcion
From app.tblCatTipoPermiso
GO
