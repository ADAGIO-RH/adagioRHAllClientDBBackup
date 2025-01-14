USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create   proc [Seguridad].[spIHistorialLoginUsuario](
	@IDUsuario int
	,@ZonaHoraria varchar(70)
	,@Browser varchar(max)
	,@GeoLocation varchar(max)
	,@FechaHora datetime
	,@LoginCorrecto bit
)
as
begin
	declare @registrosAfectados int;
	declare @IDZonaHoraria int = (select id from Tzdb.Zones where [Name] = @ZonaHoraria)	-- por ejemplo @ZonaHoraria = 'America/Mexico_City'
	begin try
		begin tran
		insert into Seguridad.tblHistorialLoginUsuario(IDUsuario, IDZonaHoraria, Browser, GeoLocation, FechaHora, LoginCorrecto)
		values(@IDUsuario, @IDZonaHoraria, @Browser, @GeoLocation, @FechaHora, @LoginCorrecto)		
		set @registrosAfectados = @@ROWCOUNT

		if @registrosAfectados = 1
			commit tran
		else
			rollback tran
	end try
	begin catch
		rollback tran
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	end catch

end
GO
