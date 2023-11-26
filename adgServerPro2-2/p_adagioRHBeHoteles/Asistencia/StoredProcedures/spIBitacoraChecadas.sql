USE [p_adagioRHBeHoteles]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Asistencia].[spIBitacoraChecadas]
(
	@IDEmpleado int = null,
	@Fecha Datetime =  null,
	@IDLector int = null,
	@Mensaje Varchar(MAX) = null
)
AS
BEGIN
 

	INSERT INTO Asistencia.tblBitacoraChecadas( IDEmpleado
												,Fecha
												,IDLector
												,Mensaje)
	Select @IDEmpleado,isnull(@Fecha,getdate()),@IDLector,@Mensaje

END
GO
