USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spBorrarDeviceCmds] 
    @ID int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	DELETE
	FROM   [zkteco].[tblDeviceCmds]
	WHERE  [ID] = @ID

	COMMIT
GO
