USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create proc Dashboard.spBuscarPermisosEspeciales(
	@IDUsuario int
) as
	select *
	from Dashboard.tblPermisosEspeciales
	where IDUsuario = @IDUsuario
GO
