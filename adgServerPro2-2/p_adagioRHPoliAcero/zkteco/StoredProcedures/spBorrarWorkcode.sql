USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spBorrarWorkcode] 
    @ID int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	DELETE
	FROM   [zkteco].[tblWorkcode]
	WHERE  [ID] = @ID

	COMMIT
GO
