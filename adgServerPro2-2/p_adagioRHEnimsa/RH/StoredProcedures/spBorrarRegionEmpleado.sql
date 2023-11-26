USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarRegionEmpleado]
(
	@IDRegionEmpleado int ,
	@IDUsuario int 
)
AS
BEGIN
    declare @IDEmpleado int = 0;

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [RH].[tblRegionEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRegionEmpleado = @IDRegionEmpleado
    	

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblRegionEmpleado]','[RH].[spBorrarRegionEmpleado]','DELETE','',@OldJSON


    select top 1 @IDEmpleado=IDEmpleado
    FROM RH.tblRegionEmpleado
    WHERE IDEmpleado = @IDEmpleado

    Delete RH.tblRegionEmpleado 
    where IDRegionEmpleado = @IDRegionEmpleado

    if OBJECT_ID('tempdb..#tblTempHistorial1') is not null
	   drop table #tblTempHistorial1;

    if OBJECT_ID('tempdb..#tblTempHistorial2') is not null
	   drop table #tblTempHistorial2;

    select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]
    INTO #tblTempHistorial1
    FROM RH.tblRegionEmpleado
    WHERE IDEmpleado = @IDEmpleado
    order by FechaIni asc

    select 
	   t1.IDRegionEmpleado
	   ,t1.IDEmpleado
	   ,t1.IDRegion
	   ,t1.FechaIni
	   ,FechaFin = case when t2.FechaIni is not null then dateadd(day,-1,t2.FechaIni) 
				else '9999-12-31' end 
    INTO #tblTempHistorial2
    from #tblTempHistorial1 t1
	   left join (select * 
				from #tblTempHistorial1) t2 on t1.[Row] = (t2.[Row]-1)

    update [TARGET]
    set 
	   [TARGET].FechaFin = [SOURCE].FechaFin
    FROM RH.tblRegionEmpleado as [TARGET]
	   join #tblTempHistorial2 as [SOURCE] on [TARGET].IDRegionEmpleado = [SOURCE].IDRegionEmpleado		

	EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
END
GO
