USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [RH].[spBuscarPosicionActualEmpleado](
	@IDEmpleado int,
	@IDUsuario int
) as

    declare @IDPosicion INT
    
	SELECT 
		@IDPosicion= IDPosicion
	FROM RH.tblCatPosiciones
	where IDEmpleado = @IDEmpleado

    
    set @IDPosicion=isnull(@IDPosicion,0);


    select @IDPosicion IDPosicion;
GO
