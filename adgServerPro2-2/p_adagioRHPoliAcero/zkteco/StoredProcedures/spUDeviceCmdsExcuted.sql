USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [zkteco].[spUDeviceCmdsExcuted] (
	@ID int
) as
	update  [zkteco].[tblDeviceCmds]
		set 
			Executed = 1
	where ID = @ID
GO
