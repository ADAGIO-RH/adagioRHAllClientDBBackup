USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure rh.spTieneContrato
(
	@IDEmpleado int
)
AS
BEGIN
	Declare @tieneContrato bit = 0,
			@FechaInicio date

	if exists(
			select * From RH.tblContratoEmpleado ce
				inner join rh.tblCatDocumentos d
					on ce.IDDocumento = d.IDDocumento
					and isnull(d.EsContrato,0) = 1
			where ce.IDEmpleado = @IDEmpleado 
		)
		BEGIN
			set @tieneContrato = 1
			set @FechaInicio = (select top 1 FechaFin From RH.tblContratoEmpleado ce
								inner join rh.tblCatDocumentos d
									on ce.IDDocumento = d.IDDocumento
									and isnull(d.EsContrato,0) = 1
							where ce.IDEmpleado = @IDEmpleado 
							order by FechaFin desc)
		END
		ELSE
		BEGIN
			set @tieneContrato = 0
			set @FechaInicio = (Select isnull(FechaAntiguedad,isnull(FechaIngreso,FechaPrimerIngreso)) from RH.tblEmpleadosMaster where IDEmpleado = @IDEmpleado)
		END

		select @tieneContrato as TieneContrato,
			   @FechaInicio as FechaInicio

END
GO
