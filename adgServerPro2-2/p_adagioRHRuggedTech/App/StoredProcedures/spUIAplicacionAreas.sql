USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [App].[spUIAplicacionAreas] 
(
	@IDAplicacion varchar(255),
	@IDArea int
)
AS
BEGIN
    

INSERT INTO [App].[tblAplicacionAreas]
           ([IDAplicacion]
           ,[IDArea])
     VALUES
           (@IDAplicacion
           ,@IDArea)

END
GO
