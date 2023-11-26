USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spControllersActions]
(
	@dtControllersActions [App].[dtControllersActions] READONLY
)
AS
    delete from [App].[tblControllersActions];
    
    insert into [App].[tblControllersActions]
    select * from @dtControllersActions
GO
