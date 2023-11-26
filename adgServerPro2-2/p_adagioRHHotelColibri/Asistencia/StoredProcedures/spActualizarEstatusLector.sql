USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc Asistencia.spActualizarEstatusLector(
	@IDLector int
	,@Estatus varchar(50)
	,@IDUsuario int
) as

	update Asistencia.tblLectores
		set Estatus = @Estatus
	where IDLector = @IDLector
GO
